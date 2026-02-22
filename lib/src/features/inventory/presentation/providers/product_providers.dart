import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository();
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

final productByIdProvider = StreamProvider.family<Product?, String>((ref, id) {
  return ref.watch(productRepositoryProvider).watchProductById(id);
});

final productSearchProvider =
    Provider.family<AsyncValue<List<Product>>, String>((ref, query) {
  final normalized = query.trim().toLowerCase();
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.whenData((products) {
    if (normalized.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(normalized) ||
          product.nameAr.toLowerCase().contains(normalized) ||
          product.nameFr.toLowerCase().contains(normalized) ||
          (product.barcode?.toLowerCase().contains(normalized) ?? false) ||
          (product.category?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  });
});

final lowStockProductsProvider = Provider<List<Product>>((ref) {
  final productsState = ref.watch(productsProvider);
  return productsState.maybeWhen(
    data: (products) =>
        products.where((product) => product.stock <= 5).toList(),
    orElse: () => <Product>[],
  );
});
