import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  ProductModel({
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

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String nameAr;

  @HiveField(3)
  late String nameFr;

  @HiveField(4)
  late double price;

  @HiveField(5)
  late double costPrice;

  @HiveField(6)
  late int stock;

  @HiveField(7)
  late String? barcode;

  @HiveField(8)
  late String? category;

  @HiveField(9)
  late String? imagePath;

  @HiveField(10)
  late String unit;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  late DateTime updatedAt;
}
