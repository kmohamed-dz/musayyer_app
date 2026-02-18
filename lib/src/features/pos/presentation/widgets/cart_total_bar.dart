import 'package:flutter/material.dart';

class CartTotalBar extends StatelessWidget {
  const CartTotalBar({
    super.key,
    required this.total,
    required this.onCheckout,
  });

  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'TOTAL: ${total.toStringAsFixed(2)} DZD',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: onCheckout,
            child: const Text('CHECKOUT'),
          ),
        ],
      ),
    );
  }
}
