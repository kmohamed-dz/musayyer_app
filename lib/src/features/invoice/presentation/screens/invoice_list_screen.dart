import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../providers/invoice_providers.dart';
import '../widgets/invoice_card.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(filteredInvoicesProvider);
    final selectedFilter = ref.watch(invoiceStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search invoice ID or customer',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(invoiceSearchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  value: 'all',
                  selected: selectedFilter,
                  onSelected: (value) => ref.read(invoiceStatusFilterProvider.notifier).state = value,
                ),
                _FilterChip(
                  label: 'Paid',
                  value: 'paid',
                  selected: selectedFilter,
                  onSelected: (value) => ref.read(invoiceStatusFilterProvider.notifier).state = value,
                ),
                _FilterChip(
                  label: 'Unpaid',
                  value: 'unpaid',
                  selected: selectedFilter,
                  onSelected: (value) => ref.read(invoiceStatusFilterProvider.notifier).state = value,
                ),
                _FilterChip(
                  label: 'Partial',
                  value: 'partial',
                  selected: selectedFilter,
                  onSelected: (value) => ref.read(invoiceStatusFilterProvider.notifier).state = value,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: invoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return const Center(child: Text('No invoices'));
                  }

                  final customersBox = Hive.box<CustomerModel>(HiveBoxes.customers);

                  return ListView.builder(
                    itemCount: invoices.length,
                    itemBuilder: (_, index) {
                      final invoice = invoices[index];
                      final customerName = invoice.customerId == null
                          ? 'Cash sale'
                          : (customersBox.get(invoice.customerId)?.name ?? 'Unknown customer');

                      return InvoiceCard(
                        invoice: invoice,
                        customerName: customerName,
                        onTap: () => context.push('/invoices/${invoice.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onSelected(value),
    );
  }
}
