class Customer {
  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.totalDebt,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double totalDebt;
  final DateTime createdAt;
}
