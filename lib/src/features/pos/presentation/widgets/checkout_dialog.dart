import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';

enum CheckoutAction { payCash, recordDebt }

class CheckoutResult {
  CheckoutResult({
    required this.action,
    required this.amountPaid,
    this.customerId,
  });

  final CheckoutAction action;
  final double amountPaid;
  final String? customerId;
}

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({
    super.key,
    required this.total,
  });

  final double total;

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  late final TextEditingController _amountPaidController;
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _amountPaidController = TextEditingController(text: widget.total.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  double get _amountPaid => double.tryParse(_amountPaidController.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final customers = Hive.box<CustomerModel>(HiveBoxes.customers).values.toList();
    final changeDue = _amountPaid - widget.total;

    return AlertDialog(
      title: const Text('Checkout'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RowItem(label: 'Total', value: '${widget.total.toStringAsFixed(2)} DZD'),
            const SizedBox(height: 12),
            TextField(
              controller: _amountPaidController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _RowItem(label: 'Change Due', value: '${changeDue.toStringAsFixed(2)} DZD'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              decoration: const InputDecoration(
                labelText: 'Customer (for debt)',
                border: OutlineInputBorder(),
              ),
              items: customers
                  .map(
                    (customer) => DropdownMenuItem<String>(
                      value: customer.id,
                      child: Text(customer.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(
              CheckoutResult(
                action: CheckoutAction.payCash,
                amountPaid: _amountPaid,
              ),
            );
          },
          child: const Text('Pay Cash'),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedCustomerId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select customer to record debt')),
              );
              return;
            }

            Navigator.of(context).pop(
              CheckoutResult(
                action: CheckoutAction.recordDebt,
                amountPaid: _amountPaid,
                customerId: _selectedCustomerId,
              ),
            );
          },
          child: const Text('Record as Debt'),
        ),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
