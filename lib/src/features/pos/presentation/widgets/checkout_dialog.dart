import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final customers = Hive.box<CustomerModel>(HiveBoxes.customers).values.toList();
    final changeDue = _amountPaid - widget.total;

    return AlertDialog(
      title: Text(l10n.checkoutTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RowItem(label: l10n.total, value: '${widget.total.toStringAsFixed(2)} ${l10n.dzd}'),
            const SizedBox(height: 12),
            TextField(
              controller: _amountPaidController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amountPaid,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _RowItem(label: l10n.changeDue, value: '${changeDue.toStringAsFixed(2)} ${l10n.dzd}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              decoration: InputDecoration(
                labelText: l10n.customerForDebt,
                border: const OutlineInputBorder(),
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
          child: Text(l10n.cancel),
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
          child: Text(l10n.payCash),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedCustomerId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.selectCustomerForDebt)),
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
          child: Text(l10n.recordAsDebt),
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
