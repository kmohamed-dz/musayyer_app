import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'stock_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = product.stock <= 2
        ? Colors.red.shade50
        : product.stock <= 5
            ? Colors.orange.shade50
            : Theme.of(context).cardColor;

    return Card(
      color: cardColor,
      child: ListTile(
        onTap: onTap,
        title: Text(product.nameAr.isNotEmpty ? product.nameAr : product.name),
        subtitle: Text('${product.price.toStringAsFixed(2)} DZD'),
        trailing: StockBadge(stock: product.stock),
      ),
    );
  }
}
