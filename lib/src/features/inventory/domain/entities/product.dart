class Product {
  Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameFr,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.barcode,
    this.category,
    this.imagePath,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String nameAr;
  final String nameFr;
  final double price;
  final double costPrice;
  final int stock;
  final String? barcode;
  final String? category;
  final String? imagePath;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stock <= 5;

  double get profitMargin => price > 0 ? ((price - costPrice) / price) * 100 : 0;

  Product copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? nameFr,
    double? price,
    double? costPrice,
    int? stock,
    String? barcode,
    String? category,
    String? imagePath,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      nameFr: nameFr ?? this.nameFr,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
