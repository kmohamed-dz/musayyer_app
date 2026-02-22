import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchProducts();
  Stream<Product?> watchProductById(String id);
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<List<Product>> searchProducts(String query);
  Future<void> upsertProduct(Product product);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, int newStock);
}
