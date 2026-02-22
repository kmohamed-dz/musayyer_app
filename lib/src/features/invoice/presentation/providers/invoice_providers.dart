import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/repositories/firestore_invoice_repository.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return FirestoreInvoiceRepository();
});

final invoicesProvider = StreamProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).watchInvoices();
});

final invoiceStatusFilterProvider = StateProvider<String>((_) => 'all');
final invoiceSearchQueryProvider = StateProvider<String>((_) => '');

final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final query = ref.watch(invoiceSearchQueryProvider).trim().toLowerCase();
  final status = ref.watch(invoiceStatusFilterProvider).toLowerCase();
  final invoicesAsync = ref.watch(invoicesProvider);
  final customersBox = Hive.box<CustomerModel>(HiveBoxes.customers);

  return invoicesAsync.whenData((invoices) {
    return invoices.where((invoice) {
      final matchesStatus = status == 'all' || invoice.status == status;
      if (!matchesStatus) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final customerName = invoice.customerId == null
          ? ''
          : (customersBox.get(invoice.customerId)?.name.toLowerCase() ?? '');

      return invoice.id.toLowerCase().contains(query) ||
          customerName.contains(query) ||
          (invoice.customerId?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});

final customerInvoicesProvider =
    Provider.family<AsyncValue<List<Invoice>>, String>((ref, customerId) {
  final invoicesAsync = ref.watch(invoicesProvider);

  return invoicesAsync.whenData((invoices) {
    final filtered = invoices
        .where((invoice) => invoice.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  });
});

final invoiceByIdProvider =
    StreamProvider.family<Invoice?, String>((ref, invoiceId) {
  return ref.watch(invoiceRepositoryProvider).watchInvoiceById(invoiceId);
});

final invoiceItemsProvider =
    Provider.family<AsyncValue<List<InvoiceItem>>, String>((ref, invoiceId) {
  final invoiceAsync = ref.watch(invoiceByIdProvider(invoiceId));
  return invoiceAsync
      .whenData((invoice) => invoice?.items ?? const <InvoiceItem>[]);
});
