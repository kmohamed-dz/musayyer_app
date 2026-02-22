import '../entities/invoice.dart';
import '../entities/invoice_item.dart';

abstract class InvoiceRepository {
  Stream<List<Invoice>> watchInvoices();
  Stream<Invoice?> watchInvoiceById(String id);
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice?> getInvoiceById(String id);
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId);
  Future<List<Invoice>> searchInvoices({
    required String query,
    required String status,
  });
  Future<void> createInvoice(Invoice invoice);
  Future<void> updateInvoice(Invoice invoice);
}
