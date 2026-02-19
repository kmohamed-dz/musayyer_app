class Payment {
  Payment({
    required this.id,
    required this.debtId,
    required this.customerId,
    required this.amount,
    required this.paidAt,
    this.notes,
  });

  final String id;
  final String debtId;
  final String customerId;
  final double amount;
  final DateTime paidAt;
  final String? notes;
}
