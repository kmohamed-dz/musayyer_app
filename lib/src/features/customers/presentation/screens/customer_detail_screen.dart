import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.customer)),
        body: Center(child: Text(l10n.customerNotFound)),
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
              trailing: Text('${customer.totalDebt.toStringAsFixed(2)} ${l10n.dzd}'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: debts.where((d) => d.remainingAmount > 0).isEmpty
                ? null
                : () => _showRecordPaymentDialog(debts),
            icon: const Icon(Icons.payments),
            label: Text(l10n.recordPayment),
          ),
          const SizedBox(height: 16),
          Text(l10n.invoices, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (invoices.isEmpty) Text(l10n.noInvoicesForCustomer),
          for (final invoice in invoices)
            ListTile(
              title: Text('${l10n.invoice} #${invoice.id.substring(0, 8)}'),
              subtitle: Text(
                '${l10n.total} ${invoice.totalAmount.toStringAsFixed(2)} ${l10n.dzd} | '
                '${l10n.paid} ${invoice.paidAmount.toStringAsFixed(2)} ${l10n.dzd}',
              ),
              trailing: Text(_statusLabel(l10n, invoice.status)),
              onTap: () => context.push('/invoices/${invoice.id}'),
            ),
          const SizedBox(height: 16),
          Text(l10n.debts, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (debts.isEmpty) Text(l10n.noDebtsForCustomer),
          for (final debt in debts)
            Card(
              child: ListTile(
                title: Text('${l10n.debt} ${debt.amount.toStringAsFixed(2)} ${l10n.dzd}'),
                subtitle: Text('${l10n.remaining} ${debt.remainingAmount.toStringAsFixed(2)} ${l10n.dzd}'),
                trailing: Text(_statusLabel(l10n, debt.status)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showRecordPaymentDialog(List<DebtModel> debts) async {
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.recordPayment),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDebtId,
                      decoration: InputDecoration(
                        labelText: l10n.debt,
                        border: const OutlineInputBorder(),
                      ),
                      items: openDebts
                          .map(
                            (debt) => DropdownMenuItem<String>(
                              value: debt.id,
                              child: Text(
                                '${debt.remainingAmount.toStringAsFixed(2)} ${l10n.dzd} (${debt.id.substring(0, 6)})',
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
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: l10n.notes,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('${l10n.date}: ${_selectedDate.toIso8601String().split('T').first}')),
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
                          child: Text(l10n.pickDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.save),
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

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'paid':
        return l10n.paid;
      case 'partial':
        return l10n.partial;
      default:
        return l10n.unpaid;
    }
  }
}
