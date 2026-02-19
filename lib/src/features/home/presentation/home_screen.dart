import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musayyer Dashboard'),
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
                const Text(
                  'Welcome back, Operator',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Demo products loaded: ${products.length}'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/inventory'),
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Open Inventory'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/pos'),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Open POS'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push('/invoices'),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Open Invoices'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('${product.price.toStringAsFixed(0)} DZD'),
                        trailing: Text('Stock: ${product.stock}'),
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
