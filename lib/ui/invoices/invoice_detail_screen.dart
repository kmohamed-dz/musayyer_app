import 'package:flutter/material.dart';

import '../../models/invoice.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(invoice.createdAtMs);
    final formattedDate = _formatDateTime(dateTime);
    final shortId = invoice.id.length > 6 ? invoice.id.substring(0, 6) : invoice.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice #$shortId',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: $formattedDate'),
            const SizedBox(height: 16),
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: invoice.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  final lineTotal = item.qty * item.price;
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Qty: ${item.qty} • Price: ${item.price.toStringAsFixed(2)}'),
                    trailing: Text(lineTotal.toStringAsFixed(2)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  invoice.total.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final date = '${dateTime.year.toString().padLeft(4, '0')}'
      '-${dateTime.month.toString().padLeft(2, '0')}'
      '-${dateTime.day.toString().padLeft(2, '0')}';
  final time = '${dateTime.hour.toString().padLeft(2, '0')}'
      ':${dateTime.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
