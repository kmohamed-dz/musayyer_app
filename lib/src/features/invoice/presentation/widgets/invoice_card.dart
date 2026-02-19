import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/invoice.dart';
import 'invoice_status_badge.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.customerName,
    required this.onTap,
  });

  final Invoice invoice;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text('#${invoice.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)),
            Text(customerName),
            Text('Total: ${invoice.totalAmount.toStringAsFixed(2)} DZD'),
          ],
        ),
        trailing: InvoiceStatusBadge(status: invoice.status),
      ),
    );
  }
}
