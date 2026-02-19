import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productDetails),
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
        error: (error, _) => Center(child: Text(error.toString())),
        data: (product) {
          if (product == null) {
            return Center(child: Text(l10n.productNotFound));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoTile(label: l10n.nameAr, value: product.nameAr),
              _InfoTile(label: l10n.nameFr, value: product.nameFr),
              _InfoTile(label: l10n.price, value: '${product.price.toStringAsFixed(2)} ${l10n.dzd}'),
              _InfoTile(
                label: l10n.costPrice,
                value: '${product.costPrice.toStringAsFixed(2)} ${l10n.dzd}',
              ),
              _InfoTile(label: l10n.stock, value: '${product.stock} ${product.unit}'),
              _InfoTile(label: l10n.category, value: product.category ?? '-'),
              _InfoTile(label: l10n.barcode, value: product.barcode ?? '-'),
              _InfoTile(
                label: l10n.profitMargin,
                value: '${product.profitMargin.toStringAsFixed(2)}%',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProductTitle),
        content: Text(l10n.deleteProductConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
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
