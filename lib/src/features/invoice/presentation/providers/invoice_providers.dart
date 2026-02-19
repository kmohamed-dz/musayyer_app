import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/hive_invoice_repository.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return HiveInvoiceRepository.fromHive();
});

class InvoicesNotifier extends AsyncNotifier<List<Invoice>> {
  InvoiceRepository get _repository => ref.read(invoiceRepositoryProvider);

  @override
  Future<List<Invoice>> build() => _repository.getAllInvoices();

  Future<void> refresh() async {
    state = AsyncData(await _repository.getAllInvoices());
  }
}

final invoicesProvider = AsyncNotifierProvider<InvoicesNotifier, List<Invoice>>(
  InvoicesNotifier.new,
);

final invoiceStatusFilterProvider = StateProvider<String>((_) => 'all');
final invoiceSearchQueryProvider = StateProvider<String>((_) => '');

final filteredInvoicesProvider = FutureProvider<List<Invoice>>((ref) {
  final query = ref.watch(invoiceSearchQueryProvider);
  final status = ref.watch(invoiceStatusFilterProvider);
  return ref.read(invoiceRepositoryProvider).searchInvoices(
        query: query,
        status: status,
      );
});

final invoiceByIdProvider = FutureProvider.family<Invoice?, String>((ref, invoiceId) {
  return ref.read(invoiceRepositoryProvider).getInvoiceById(invoiceId);
});

final invoiceItemsProvider = FutureProvider.family<List<InvoiceItem>, String>((ref, invoiceId) {
  return ref.read(invoiceRepositoryProvider).getInvoiceItems(invoiceId);
});
