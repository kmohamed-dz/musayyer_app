import 'package:flutter/material.dart';
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
    final debtBox = Hive.box<DebtModel>(HiveBoxes.debts);
    final customerBox = Hive.box<CustomerModel>(HiveBoxes.customers);

    return Scaffold(
      appBar: AppBar(title: const Text('Debts')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
                ChoiceChip(
                  label: const Text('Overdue'),
                  selected: _filter == 'overdue',
                  onSelected: (_) => setState(() => _filter = 'overdue'),
                ),
                ChoiceChip(
                  label: const Text('Recent'),
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
                    return const Center(child: Text('No open debts'));
                  }

                  return ListView.builder(
                    itemCount: debts.length,
                    itemBuilder: (_, index) {
                      final debt = debts[index];
                      final customerName = customerBox.get(debt.customerId)?.name ?? 'Unknown';
                      final days = now.difference(debt.createdAt).inDays;

                      return Card(
                        child: ListTile(
                          title: Text(customerName),
                          subtitle: Text(
                            'Original ${debt.amount.toStringAsFixed(2)} | Remaining ${debt.remainingAmount.toStringAsFixed(2)}\n$days days ago',
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
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final save = await showDialog<bool>(
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
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text(selectedDate.toIso8601String().split('T').first)),
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
