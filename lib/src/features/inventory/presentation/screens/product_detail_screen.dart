import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            onPressed: () => context.push('/inventory/edit/$productId'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoTile(label: 'Name (AR)', value: product.nameAr),
              _InfoTile(label: 'Name (FR)', value: product.nameFr),
              _InfoTile(label: 'Price', value: '${product.price.toStringAsFixed(2)} DZD'),
              _InfoTile(
                label: 'Cost Price',
                value: '${product.costPrice.toStringAsFixed(2)} DZD',
              ),
              _InfoTile(label: 'Stock', value: '${product.stock} ${product.unit}'),
              _InfoTile(label: 'Category', value: product.category ?? '-'),
              _InfoTile(label: 'Barcode', value: product.barcode ?? '-'),
              _InfoTile(
                label: 'Profit Margin',
                value: '${product.profitMargin.toStringAsFixed(2)}%',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await ref.read(productsProvider.notifier).deleteProduct(productId);
    if (context.mounted) {
      context.pop();
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
