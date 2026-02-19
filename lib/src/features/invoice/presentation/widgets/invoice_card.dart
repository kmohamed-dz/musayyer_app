import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/invoice.dart';
import 'invoice_status_badge.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.customerName,
    required this.onTap,
  });

  final Invoice invoice;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text('#${invoice.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)),
            Text(customerName),
            Text('${l10n.total}: ${invoice.totalAmount.toStringAsFixed(2)} ${l10n.dzd}'),
          ],
        ),
        trailing: InvoiceStatusBadge(status: invoice.status),
      ),
    );
  }
}
