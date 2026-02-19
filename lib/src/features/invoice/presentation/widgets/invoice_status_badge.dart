import 'package:flutter/material.dart';

class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  Color _background() {
    switch (status) {
      case 'paid':
        return Colors.green.shade100;
      case 'partial':
        return Colors.orange.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  Color _foreground() {
    switch (status) {
      case 'paid':
        return Colors.green.shade900;
      case 'partial':
        return Colors.orange.shade900;
      default:
        return Colors.red.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _background(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _foreground(),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
