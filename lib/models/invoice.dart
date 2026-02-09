class Invoice {
  const Invoice({
    required this.id,
    required this.createdAtMs,
    required this.items,
    required this.total,
  });

  final String id;
  final int createdAtMs;
  final List<InvoiceItem> items;
  final double total;
}

class InvoiceItem {
  const InvoiceItem({
    required this.productId,
    required this.name,
    required this.barcode,
    required this.qty,
    required this.price,
  });

  final String productId;
  final String name;
  final String barcode;
  final double qty;
  final double price;
}
