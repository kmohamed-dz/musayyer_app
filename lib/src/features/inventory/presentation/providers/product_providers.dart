import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/hive_product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return HiveProductRepository.fromHive();
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  ProductRepository get _repository => ref.read(productRepositoryProvider);

  @override
  Future<List<Product>> build() async {
    return _repository.getAllProducts();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = AsyncData(await _repository.getAllProducts());
  }

  Future<void> refresh() async {
    state = AsyncData(await _repository.getAllProducts());
  }

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    await refresh();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await refresh();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await refresh();
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _repository.updateStock(productId, newStock);
    await refresh();
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) {
  return ref.read(productRepositoryProvider).getProductById(id);
});

final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) {
  return ref.read(productRepositoryProvider).searchProducts(query);
});

final lowStockProductsProvider = Provider<List<Product>>((ref) {
  final productsState = ref.watch(productsProvider);
  return productsState.maybeWhen(
    data: (products) => products.where((product) => product.stock <= 5).toList(),
    orElse: () => <Product>[],
  );
});

final productsBoxNameProvider = Provider<String>((_) => HiveBoxes.products);
final productsModelTypeProvider = Provider<Type>((_) => ProductModel);
