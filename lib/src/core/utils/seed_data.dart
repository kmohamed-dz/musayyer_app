import 'package:hive/hive.dart';

import '../db/hive_boxes.dart';
import '../../features/inventory/data/models/product_model.dart';

class SeedData {
  static Future<void> seedDemoProducts() async {
    final productsBox = Hive.box<ProductModel>(HiveBoxes.products);
    if (productsBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final demoProducts = [
      ProductModel(
        id: 'prod-rice',
        name: 'Rice',
        nameAr: 'أرز',
        nameFr: 'Riz',
        price: 220,
        costPrice: 170,
        stock: 40,
        barcode: '613100000001',
        category: 'Food',
        imagePath: null,
        unit: 'kg',
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-oil',
        name: 'Oil',
        nameAr: 'زيت',
        nameFr: 'Huile',
        price: 850,
        costPrice: 760,
        stock: 30,
        barcode: '613100000002',
        category: 'Food',
        imagePath: null,
        unit: 'l',
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-sugar',
        name: 'Sugar',
        nameAr: 'سكر',
        nameFr: 'Sucre',
        price: 180,
        costPrice: 140,
        stock: 50,
        barcode: '613100000003',
        category: 'Food',
        imagePath: null,
        unit: 'kg',
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-flour',
        name: 'Flour',
        nameAr: 'فرينة',
        nameFr: 'Farine',
        price: 130,
        costPrice: 95,
        stock: 60,
        barcode: '613100000004',
        category: 'Food',
        imagePath: null,
        unit: 'kg',
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-tomato-paste',
        name: 'Tomato Paste',
        nameAr: 'مصبر طماطم',
        nameFr: 'Concentré de tomate',
        price: 190,
        costPrice: 150,
        stock: 35,
        barcode: '613100000005',
        category: 'Food',
        imagePath: null,
        unit: 'pcs',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final product in demoProducts) {
      await productsBox.put(product.id, product);
    }
  }
}
