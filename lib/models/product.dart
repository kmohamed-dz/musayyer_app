class Product {
  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.unit,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    required this.createdAtMs,
  });

  final String id;
  final String name;
  final String barcode;
  final String unit;
  final double quantity;
  final double purchasePrice;
  final double salePrice;
  final int createdAtMs;

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    String? unit,
    double? quantity,
    double? purchasePrice,
    double? salePrice,
    int? createdAtMs,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }
}
