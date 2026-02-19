import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../debt/data/models/debt_model.dart';
import '../../../debt/presentation/providers/debt_providers.dart';
import '../../../invoice/data/models/invoice_model.dart';
import '../../data/models/customer_model.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  DateTime _selectedDate = DateTime.now();

  CustomerModel? get _customer =>
      Hive.box<CustomerModel>(HiveBoxes.customers).get(widget.customerId);

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer')),
        body: const Center(child: Text('Customer not found')),
      );
    }

    final invoices = Hive.box<InvoiceModel>(HiveBoxes.invoices).values
        .where((invoice) => invoice.customerId == customer.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final debts = Hive.box<DebtModel>(HiveBoxes.debts).values
        .where((debt) => debt.customerId == customer.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(customer.name),
              subtitle: Text('${customer.phone ?? '-'}\n${customer.address ?? '-'}'),
              isThreeLine: true,
              trailing: Text('${customer.totalDebt.toStringAsFixed(2)} DZD'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: debts.where((d) => d.remainingAmount > 0).isEmpty
                ? null
                : () => _showRecordPaymentDialog(customer, debts),
            icon: const Icon(Icons.payments),
            label: const Text('Record Payment'),
          ),
          const SizedBox(height: 16),
          const Text('Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (invoices.isEmpty) const Text('No invoices for this customer'),
          for (final invoice in invoices)
            ListTile(
              title: Text('Invoice #${invoice.id.substring(0, 8)}'),
              subtitle: Text(
                'Total ${invoice.totalAmount.toStringAsFixed(2)} | Paid ${invoice.paidAmount.toStringAsFixed(2)}',
              ),
              trailing: Text(invoice.status),
              onTap: () => context.push('/invoices/${invoice.id}'),
            ),
          const SizedBox(height: 16),
          const Text('Debts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (debts.isEmpty) const Text('No debts for this customer'),
          for (final debt in debts)
            Card(
              child: ListTile(
                title: Text('Debt ${debt.amount.toStringAsFixed(2)} DZD'),
                subtitle: Text('Remaining ${debt.remainingAmount.toStringAsFixed(2)} DZD'),
                trailing: Text(debt.status),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showRecordPaymentDialog(CustomerModel customer, List<DebtModel> debts) async {
    final openDebts = debts.where((debt) => debt.remainingAmount > 0).toList();
    if (openDebts.isEmpty) {
      return;
    }

    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedDebtId = openDebts.first.id;
    _selectedDate = DateTime.now();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Record Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDebtId,
                      decoration: const InputDecoration(
                        labelText: 'Debt',
                        border: OutlineInputBorder(),
                      ),
                      items: openDebts
                          .map(
                            (debt) => DropdownMenuItem<String>(
                              value: debt.id,
                              child: Text(
                                '${debt.remainingAmount.toStringAsFixed(2)} DZD (${debt.id.substring(0, 6)})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedDebtId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('Date: ${_selectedDate.toIso8601String().split('T').first}')),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      return;
    }

    final debt = openDebts.firstWhere((d) => d.id == selectedDebtId);

    await ref.read(debtPaymentServiceProvider).recordPayment(
          debt: debt,
          amount: amount,
          paidAt: _selectedDate,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

    if (mounted) {
      setState(() {});
    }
  }
}
