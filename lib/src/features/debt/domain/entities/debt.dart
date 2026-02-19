class Debt {
  Debt({
    required this.id,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.remainingAmount,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String customerId;
  final String? invoiceId;
  final double amount;
  final double remainingAmount;
  final DateTime createdAt;
  final String status;
}
