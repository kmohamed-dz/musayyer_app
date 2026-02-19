import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../debt/data/models/debt_model.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/providers/product_providers.dart';
import '../../../invoice/data/models/invoice_item_model.dart';
import '../../../invoice/data/models/invoice_model.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_total_bar.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/product_search_delegate.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanAndAddProduct() async {
    final l10n = AppLocalizations.of(context)!;
    final barcode = await context.push<String>('/scanner');
    if (barcode == null || barcode.isEmpty || !mounted) {
      return;
    }

    final product = await ref.read(productRepositoryProvider).getProductByBarcode(barcode);
    if (product == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productNotFoundForScannedBarcode)),
        );
      }
      return;
    }

    ref.read(cartProvider.notifier).addProduct(product);
  }

  Future<void> _checkout() async {
    final l10n = AppLocalizations.of(context)!;
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cartEmpty)),
      );
      return;
    }

    final result = await showDialog<CheckoutResult>(
      context: context,
      builder: (_) => CheckoutDialog(total: cart.total),
    );

    if (result == null || !mounted) {
      return;
    }

    if (result.action == CheckoutAction.payCash && result.amountPaid < cart.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.amountPaidMustCoverTotal)),
      );
      return;
    }

    await _processCheckout(cart.items, cart.total, result);
  }

  Future<void> _processCheckout(
    List<CartItem> items,
    double total,
    CheckoutResult result,
  ) async {
    final invoiceId = const Uuid().v4();
    final now = DateTime.now();

    final itemBox = Hive.box<InvoiceItemModel>(HiveBoxes.invoiceItems);
    final invoiceBox = Hive.box<InvoiceModel>(HiveBoxes.invoices);
    final debtBox = Hive.box<DebtModel>(HiveBoxes.debts);
    final customerBox = Hive.box<CustomerModel>(HiveBoxes.customers);

    final itemIds = <String>[];

    for (final item in items) {
      final invoiceItemId = const Uuid().v4();
      itemIds.add(invoiceItemId);

      final invoiceItem = InvoiceItemModel(
        id: invoiceItemId,
        productId: item.product.id,
        productName: item.product.name,
        unitPrice: item.product.price,
        quantity: item.quantity,
        subtotal: item.subtotal,
      );

      await itemBox.put(invoiceItemId, invoiceItem);

      final newStock = (item.product.stock - item.quantity).clamp(0, 999999);
      await ref.read(productRepositoryProvider).updateStock(item.product.id, newStock);
    }

    final isCash = result.action == CheckoutAction.payCash;
    final paidAmount = isCash ? total : 0.0;
    final status = isCash ? 'paid' : 'unpaid';

    final invoice = InvoiceModel(
      id: invoiceId,
      customerId: result.customerId,
      itemIds: itemIds,
      totalAmount: total,
      paidAmount: paidAmount,
      createdAt: now,
      status: status,
      notes: null,
    );

    await invoiceBox.put(invoiceId, invoice);

    if (!isCash) {
      final customerId = result.customerId!;
      final debtId = const Uuid().v4();

      final debt = DebtModel(
        id: debtId,
        customerId: customerId,
        invoiceId: invoiceId,
        amount: total,
        remainingAmount: total,
        createdAt: now,
        status: 'open',
      );
      await debtBox.put(debtId, debt);

      final customer = customerBox.get(customerId);
      if (customer != null) {
        customer.totalDebt += total;
        await customer.save();
      }
    }

    ref.read(cartProvider.notifier).clearCart();
    await ref.read(productsProvider.notifier).refresh();

    if (mounted) {
      context.go('/invoices/$invoiceId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = ref.watch(cartProvider);
    final productsAsync = _query.trim().isEmpty
        ? ref.watch(productsProvider)
        : ref.watch(productSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pointOfSale),
        actions: [
          IconButton(
            onPressed: () async {
              final product = await showSearch<Product?>(
                context: context,
                delegate: ProductSearchDelegate(ref),
              );
              if (product != null) {
                ref.read(cartProvider.notifier).addProduct(product);
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchProduct,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _scanAndAddProduct,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.products,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: productsAsync.when(
                            data: (products) => _ProductResultList(
                              products: products,
                              onTap: (product) =>
                                  ref.read(cartProvider.notifier).addProduct(product),
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(child: Text(error.toString())),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.cart} (${cart.itemCount})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: cart.items.isEmpty
                              ? Center(child: Text(l10n.noItemsInCart))
                              : ListView.builder(
                                  itemCount: cart.items.length,
                                  itemBuilder: (_, index) {
                                    final item = cart.items[index];
                                    return CartItemTile(
                                      item: item,
                                      onIncrement: () => ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(item.product.id, item.quantity + 1),
                                      onDecrement: () => ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(item.product.id, item.quantity - 1),
                                      onRemove: () =>
                                          ref.read(cartProvider.notifier).removeProduct(item.product.id),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            CartTotalBar(
              total: cart.total,
              onCheckout: _checkout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductResultList extends StatelessWidget {
  const _ProductResultList({
    required this.products,
    required this.onTap,
  });

  final List<Product> products;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (products.isEmpty) {
      return Center(child: Text(l10n.noMatchingProducts));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            onTap: () => onTap(product),
            title: Text(product.nameAr.isNotEmpty ? product.nameAr : product.name),
            subtitle: Text(
              '${product.price.toStringAsFixed(2)} ${l10n.dzd} • ${l10n.stock} ${product.stock}',
            ),
            trailing: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
