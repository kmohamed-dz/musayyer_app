import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice.dart';
import '../../state/app_state.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final invoices = state.invoices;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoices'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InvoiceList(
              invoices: _filterToday(invoices),
              emptyLabel: 'No invoices today.',
            ),
            _InvoiceList(
              invoices: invoices,
              emptyLabel: 'No invoices yet.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.emptyLabel,
  });

  final List<Invoice> invoices;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final dateTime = DateTime.fromMillisecondsSinceEpoch(invoice.createdAtMs);

        return Card(
          child: ListTile(
            title: Text(_formatDateTime(dateTime)),
            subtitle: Text('${invoice.items.length} items'),
            trailing: Text(invoice.total.toStringAsFixed(2)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceDetailScreen(invoice: invoice),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

List<Invoice> _filterToday(List<Invoice> invoices) {
  final now = DateTime.now();
  return invoices.where((invoice) {
    final date = DateTime.fromMillisecondsSinceEpoch(invoice.createdAtMs);
    return _isSameDay(date, now);
  }).toList();
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDateTime(DateTime dateTime) {
  final date = '${dateTime.year.toString().padLeft(4, '0')}'
      '-${dateTime.month.toString().padLeft(2, '0')}'
      '-${dateTime.day.toString().padLeft(2, '0')}';
  final time = '${dateTime.hour.toString().padLeft(2, '0')}'
      ':${dateTime.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
