import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

extension ProductModelMapper on ProductModel {
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      nameAr: nameAr,
      nameFr: nameFr,
      price: price,
      costPrice: costPrice,
      stock: stock,
      barcode: barcode,
      category: category,
      imagePath: imagePath,
      unit: unit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ProductEntityMapper on Product {
  ProductModel toModel() {
    return ProductModel(
      id: id,
      name: name,
      nameAr: nameAr,
      nameFr: nameFr,
      price: price,
      costPrice: costPrice,
      stock: stock,
      barcode: barcode,
      category: category,
      imagePath: imagePath,
      unit: unit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class HiveProductRepository implements ProductRepository {
  HiveProductRepository(this._productsBox);

  final Box<ProductModel> _productsBox;

  factory HiveProductRepository.fromHive() {
    return HiveProductRepository(Hive.box<ProductModel>(HiveBoxes.products));
  }

  @override
  Stream<List<Product>> watchProducts() async* {
    yield await getAllProducts();
    yield* _productsBox.watch().asyncMap((_) => getAllProducts());
  }

  @override
  Stream<Product?> watchProductById(String id) async* {
    yield await getProductById(id);
    yield* _productsBox
        .watch(key: id)
        .map((_) => _productsBox.get(id)?.toEntity());
  }

  @override
  Future<void> upsertProduct(Product product) async {
    await _productsBox.put(product.id, product.toModel());
  }

  @override
  Future<void> addProduct(Product product) async {
    await upsertProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productsBox.delete(id);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final products =
        _productsBox.values.map((model) => model.toEntity()).toList();
    products.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return products;
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    for (final model in _productsBox.values) {
      final value = model.barcode?.trim();
      if (value != null && value.isNotEmpty && value == barcode.trim()) {
        return model.toEntity();
      }
    }
    return null;
  }

  @override
  Future<Product?> getProductById(String id) async {
    return _productsBox.get(id)?.toEntity();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getAllProducts();
    }

    return _productsBox.values
        .where((model) {
          return model.name.toLowerCase().contains(normalized) ||
              model.nameAr.toLowerCase().contains(normalized) ||
              model.nameFr.toLowerCase().contains(normalized) ||
              (model.barcode?.toLowerCase().contains(normalized) ?? false) ||
              (model.category?.toLowerCase().contains(normalized) ?? false);
        })
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> updateProduct(Product product) async {
    await upsertProduct(product);
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    final existing = _productsBox.get(productId);
    if (existing == null) return;

    existing.stock = newStock;
    existing.updatedAt = DateTime.now();
    await existing.save();
  }
}
