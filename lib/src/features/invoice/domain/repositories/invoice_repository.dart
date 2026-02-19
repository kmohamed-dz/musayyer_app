import '../entities/invoice.dart';
import '../entities/invoice_item.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice?> getInvoiceById(String id);
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId);
  Future<List<Invoice>> searchInvoices({
    required String query,
    required String status,
  });
  Future<void> updateInvoice(Invoice invoice);
}
