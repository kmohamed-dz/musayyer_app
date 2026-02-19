class Invoice {
  Invoice({
    required this.id,
    this.customerId,
    required this.itemIds,
    required this.totalAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.status,
    this.notes,
  });

  final String id;
  final String? customerId;
  final List<String> itemIds;
  final double totalAmount;
  final double paidAmount;
  final DateTime createdAt;
  final String status;
  final String? notes;

  double get remainingAmount => totalAmount - paidAmount;
}
