import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../debt/data/models/debt_model.dart';
import '../../../debt/data/models/payment_model.dart';
import '../pdf/invoice_pdf_generator.dart';
import '../widgets/invoice_status_badge.dart';
import '../../data/models/invoice_item_model.dart';
import '../../data/models/invoice_model.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  final String invoiceId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _exporting = false;

  InvoiceModel? get _invoice =>
      Hive.box<InvoiceModel>(HiveBoxes.invoices).get(widget.invoiceId);

  List<InvoiceItemModel> _items(InvoiceModel invoice) {
    final itemBox = Hive.box<InvoiceItemModel>(HiveBoxes.invoiceItems);
    return invoice.itemIds.map((id) => itemBox.get(id)).whereType<InvoiceItemModel>().toList();
  }

  String _customerName(InvoiceModel invoice) {
    if (invoice.customerId == null) {
      return 'Cash sale';
    }

    final customer = Hive.box<CustomerModel>(HiveBoxes.customers).get(invoice.customerId);
    return customer?.name ?? 'Unknown customer';
  }

  Future<void> _exportPdf(InvoiceModel invoice, List<InvoiceItemModel> items) async {
    setState(() {
      _exporting = true;
    });

    try {
      final shopName =
          Hive.box<CustomerModel>(HiveBoxes.customers).isEmpty ? 'Musayyer Shop' : 'Musayyer Shop';

      final filePath = await InvoicePdfGenerator().generate(
        invoice: invoice,
        items: items,
        shopName: shopName,
        customerName: _customerName(invoice),
      );

      await Share.shareXFiles([XFile(filePath)]);
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<void> _recordPayment(InvoiceModel invoice) async {
    final controller = TextEditingController();
    final notesController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final parsedAmount = amount ?? 0;
    if (parsedAmount <= 0) {
      return;
    }

    final remaining = invoice.totalAmount - invoice.paidAmount;
    final paymentAmount = min(parsedAmount, remaining);

    final updatedPaidAmount = invoice.paidAmount + paymentAmount;
    final updatedStatus = updatedPaidAmount >= invoice.totalAmount
        ? 'paid'
        : updatedPaidAmount > 0
            ? 'partial'
            : 'unpaid';

    invoice.paidAmount = updatedPaidAmount;
    invoice.status = updatedStatus;
    await invoice.save();

    final debtBox = Hive.box<DebtModel>(HiveBoxes.debts);
    final paymentBox = Hive.box<PaymentModel>(HiveBoxes.payments);

    DebtModel? linkedDebt;
    for (final debt in debtBox.values) {
      if (debt.invoiceId == invoice.id && debt.status == 'open') {
        linkedDebt = debt;
        break;
      }
    }

    if (linkedDebt != null) {
      final payment = PaymentModel(
        id: const Uuid().v4(),
        debtId: linkedDebt.id,
        customerId: linkedDebt.customerId,
        amount: paymentAmount,
        paidAt: DateTime.now(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );
      await paymentBox.put(payment.id, payment);

      linkedDebt.remainingAmount = max(0, linkedDebt.remainingAmount - paymentAmount);
      linkedDebt.status = linkedDebt.remainingAmount <= 0 ? 'paid' : 'open';
      await linkedDebt.save();

      final customerBox = Hive.box<CustomerModel>(HiveBoxes.customers);
      final customer = customerBox.get(linkedDebt.customerId);
      if (customer != null) {
        final totalDebt = debtBox.values
            .where((debt) => debt.customerId == customer.id)
            .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);
        customer.totalDebt = totalDebt;
        await customer.save();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _invoice;
    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    final items = _items(invoice);
    final remaining = invoice.totalAmount - invoice.paidAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.id.substring(0, 8)}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)}'),
            subtitle: Text('Customer: ${_customerName(invoice)}'),
            trailing: InvoiceStatusBadge(status: invoice.status),
          ),
          const SizedBox(height: 12),
          DataTable(
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Unit Price')),
              DataColumn(label: Text('Subtotal')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(Text(item.productName)),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text(item.unitPrice.toStringAsFixed(2))),
                      DataCell(Text(item.subtotal.toStringAsFixed(2))),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: '${invoice.totalAmount.toStringAsFixed(2)} DZD'),
          _SummaryRow(label: 'Total', value: '${invoice.totalAmount.toStringAsFixed(2)} DZD'),
          _SummaryRow(label: 'Paid', value: '${invoice.paidAmount.toStringAsFixed(2)} DZD'),
          _SummaryRow(label: 'Remaining', value: '${remaining.toStringAsFixed(2)} DZD'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _exporting ? null : () => _exportPdf(invoice, items),
            icon: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
          ),
          if (invoice.status == 'unpaid' || invoice.status == 'partial')
            const SizedBox(height: 8),
          if (invoice.status == 'unpaid' || invoice.status == 'partial')
            OutlinedButton.icon(
              onPressed: () => _recordPayment(invoice),
              icon: const Icon(Icons.payments),
              label: const Text('Record Payment'),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
