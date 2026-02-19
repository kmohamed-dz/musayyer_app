import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({
    super.key,
    required this.stock,
  });

  final int stock;

  Color _backgroundColor(BuildContext context) {
    if (stock <= 2) {
      return Colors.red.shade100;
    }
    if (stock <= 5) {
      return Colors.orange.shade100;
    }
    return Colors.green.shade100;
  }

  Color _foregroundColor() {
    if (stock <= 2) {
      return Colors.red.shade900;
    }
    if (stock <= 5) {
      return Colors.orange.shade900;
    }
    return Colors.green.shade900;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.stockValue(stock),
        style: TextStyle(
          color: _foregroundColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
