import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
              '${l10n.total}: ${total.toStringAsFixed(2)} ${l10n.dzd}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: onCheckout,
            child: Text(l10n.checkout),
          ),
        ],
      ),
    );
  }
}
