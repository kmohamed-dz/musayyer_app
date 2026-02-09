import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import 'scanner_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final List<InvoiceItem> _cartItems = [];
  Product? _selectedProduct;
  final TextEditingController _manualQtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _manualQtyController.dispose();
    super.dispose();
  }

  void _addToCart(Product product, double qty) {
    if (qty <= 0) {
      return;
    }

    if (qty > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough stock')),
      );
      qty = product.quantity;
    }

    if (qty <= 0) {
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex == -1) {
      _cartItems.add(
        InvoiceItem(
          productId: product.id,
          name: product.name,
          barcode: product.barcode,
          qty: qty,
          price: product.salePrice,
        ),
      );
    } else {
      final existing = _cartItems[existingIndex];
      final updatedQty = existing.qty + qty;
      if (updatedQty > product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough stock')),
        );
        _cartItems[existingIndex] = InvoiceItem(
          productId: existing.productId,
          name: existing.name,
          barcode: existing.barcode,
          qty: product.quantity,
          price: existing.price,
        );
      } else {
        _cartItems[existingIndex] = InvoiceItem(
          productId: existing.productId,
          name: existing.name,
          barcode: existing.barcode,
          qty: updatedQty,
          price: existing.price,
        );
      }
    }

    setState(() {});
  }

  void _updateQty(Product product, InvoiceItem item, double delta) {
    final newQty = item.qty + delta;
    if (newQty <= 0) {
      _cartItems.remove(item);
      setState(() {});
      return;
    }

    if (newQty > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough stock')),
      );
      return;
    }

    final index = _cartItems.indexOf(item);
    _cartItems[index] = InvoiceItem(
      productId: item.productId,
      name: item.name,
      barcode: item.barcode,
      qty: newQty,
      price: item.price,
    );
    setState(() {});
  }

  double get _total => _cartItems.fold(0.0, (sum, item) => sum + item.qty * item.price);

  Future<void> _confirmSale(AppState state) async {
    if (_cartItems.isEmpty) {
      return;
    }
    await state.createInvoice(List<InvoiceItem>.from(_cartItems));
    setState(() {
      _cartItems.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final products = state.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.scanMode)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final product = await Navigator.push<Product?>(
                      context,
                      MaterialPageRoute(builder: (_) => const ScannerScreen()),
                    );
                    if (product != null) {
                      _addToCart(product, 1);
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan barcode'),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(labelText: 'Select product'),
                      items: products
                          .map(
                            (product) => DropdownMenuItem(
                              value: product,
                              child: Text(product.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _manualQtyController,
                      decoration: const InputDecoration(labelText: 'Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      final product = _selectedProduct;
                      if (product == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Select a product first')),
                        );
                        return;
                      }
                      final qty = double.tryParse(_manualQtyController.text) ?? 0;
                      _addToCart(product, qty);
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : ListView.separated(
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        final product = products.firstWhere(
                          (p) => p.id == item.productId,
                          orElse: () => Product(
                            id: item.productId,
                            name: item.name,
                            barcode: item.barcode,
                            unit: 'unit',
                            quantity: 0,
                            purchasePrice: 0,
                            salePrice: item.price,
                            createdAtMs: 0,
                          ),
                        );

                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('Qty: ${item.qty} • ${item.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _updateQty(product, item, -1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                IconButton(
                                  onPressed: () => _updateQty(product, item, 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _cartItems.remove(item);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                FilledButton(
                  onPressed: _cartItems.isEmpty ? null : () => _confirmSale(state),
                  child: const Text('Confirm Sale'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
