import 'package:cloud_firestore/cloud_firestore.dart';

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

  double get profitMargin =>
      price > 0 ? ((price - costPrice) / price) * 100 : 0;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'nameFr': nameFr,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'barcode': barcode,
      'category': category,
      'imagePath': imagePath,
      'unit': unit,
      'createdAtMs': createdAt.millisecondsSinceEpoch,
      'updatedAtMs': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final now = DateTime.now();
    return Product(
      id: id,
      name: (map['name'] as String?) ?? '',
      nameAr: (map['nameAr'] as String?) ?? '',
      nameFr: (map['nameFr'] as String?) ?? '',
      price: _toDouble(map['price']),
      costPrice: _toDouble(map['costPrice']),
      stock: _toInt(map['stock']),
      barcode: map['barcode'] as String?,
      category: map['category'] as String?,
      imagePath: map['imagePath'] as String?,
      unit: (map['unit'] as String?) ?? 'pcs',
      createdAt: _toDateTime(map['createdAtMs'], fallback: now),
      updatedAt: _toDateTime(map['updatedAtMs'], fallback: now),
    );
  }

  factory Product.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return Product.fromMap(data, id: snapshot.id);
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

int _toInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime _toDateTime(
  dynamic value, {
  required DateTime fallback,
}) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? fallback;
  }
  return fallback;
}
