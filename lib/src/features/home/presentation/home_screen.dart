import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/db/hive_boxes.dart';
import '../../../core/di/providers.dart';
import '../../../core/storage/storage_keys.dart';
import '../../inventory/data/models/product_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(localStorageProvider).remove(StorageKeys.authToken);
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<ProductModel>(HiveBoxes.products).listenable(),
          builder: (_, Box<ProductModel> box, __) {
            final products = box.values.toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.welcomeBack}, ${l10n.operator}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(l10n.demoProductsLoaded(products.length)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/inventory'),
                  icon: const Icon(Icons.inventory_2),
                  label: Text(l10n.openInventory),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/pos'),
                  icon: const Icon(Icons.point_of_sale),
                  label: Text(l10n.openPos),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/invoices'),
                  icon: const Icon(Icons.receipt_long),
                  label: Text(l10n.openInvoices),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/customers'),
                  icon: const Icon(Icons.people),
                  label: Text(l10n.openCustomers),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/debts'),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: Text(l10n.openDebts),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('${product.price.toStringAsFixed(0)} ${l10n.dzd}'),
                        trailing: Text(l10n.stockValue(product.stock)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
