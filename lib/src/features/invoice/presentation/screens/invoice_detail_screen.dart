import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../data/models/invoice_item_model.dart';
import '../../data/models/invoice_model.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  final String invoiceId;

  @override
  Widget build(BuildContext context) {
    final invoiceBox = Hive.box<InvoiceModel>(HiveBoxes.invoices);
    final invoiceItemBox = Hive.box<InvoiceItemModel>(HiveBoxes.invoiceItems);
    final invoice = invoiceBox.get(invoiceId);

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    final items = invoice.itemIds
        .map((id) => invoiceItemBox.get(id))
        .whereType<InvoiceItemModel>()
        .toList();

    final remaining = invoice.totalAmount - invoice.paidAmount;

    return Scaffold(
      appBar: AppBar(title: Text('Invoice ${invoice.id.substring(0, 8)}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${invoice.status}'),
          const SizedBox(height: 8),
          Text('Total: ${invoice.totalAmount.toStringAsFixed(2)} DZD'),
          Text('Paid: ${invoice.paidAmount.toStringAsFixed(2)} DZD'),
          Text('Remaining: ${remaining.toStringAsFixed(2)} DZD'),
          const Divider(height: 24),
          for (final item in items)
            ListTile(
              title: Text(item.productName),
              subtitle: Text('${item.quantity} x ${item.unitPrice.toStringAsFixed(2)}'),
              trailing: Text(item.subtotal.toStringAsFixed(2)),
            ),
        ],
      ),
    );
  }
}
