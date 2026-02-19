import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/models/debt_model.dart';
import '../providers/debt_providers.dart';

class DebtListScreen extends ConsumerStatefulWidget {
  const DebtListScreen({super.key});

  @override
  ConsumerState<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends ConsumerState<DebtListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final debtBox = Hive.box<DebtModel>(HiveBoxes.debts);
    final customerBox = Hive.box<CustomerModel>(HiveBoxes.customers);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debts)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.all),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
                ChoiceChip(
                  label: Text(l10n.overdue),
                  selected: _filter == 'overdue',
                  onSelected: (_) => setState(() => _filter = 'overdue'),
                ),
                ChoiceChip(
                  label: Text(l10n.recent),
                  selected: _filter == 'recent',
                  onSelected: (_) => setState(() => _filter = 'recent'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: debtBox.listenable(),
                builder: (_, Box<DebtModel> value, __) {
                  final now = DateTime.now();
                  final debts = value.values
                      .where((debt) => debt.remainingAmount > 0)
                      .where((debt) {
                        final days = now.difference(debt.createdAt).inDays;
                        if (_filter == 'overdue') {
                          return days > 30;
                        }
                        if (_filter == 'recent') {
                          return days <= 30;
                        }
                        return true;
                      })
                      .toList()
                    ..sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));

                  if (debts.isEmpty) {
                    return Center(child: Text(l10n.noOpenDebts));
                  }

                  return ListView.builder(
                    itemCount: debts.length,
                    itemBuilder: (_, index) {
                      final debt = debts[index];
                      final customerName = customerBox.get(debt.customerId)?.name ?? l10n.unknownCustomer;
                      final days = now.difference(debt.createdAt).inDays;

                      return Card(
                        child: ListTile(
                          title: Text(customerName),
                          subtitle: Text(
                            '${l10n.original} ${debt.amount.toStringAsFixed(2)} ${l10n.dzd} | '
                            '${l10n.remaining} ${debt.remainingAmount.toStringAsFixed(2)} ${l10n.dzd}\n'
                            '${l10n.daysAgo(days)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            onPressed: () => _recordPayment(debt),
                            icon: const Icon(Icons.payments),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPayment(DebtModel debt) async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final save = await showDialog<bool>(
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
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: l10n.notes,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${l10n.date}: ${selectedDate.toIso8601String().split('T').first}'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
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

    if (save != true) {
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      return;
    }

    await ref.read(debtPaymentServiceProvider).recordPayment(
          debt: debt,
          amount: amount,
          paidAt: selectedDate,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

    if (mounted) {
      setState(() {});
    }
  }
}
