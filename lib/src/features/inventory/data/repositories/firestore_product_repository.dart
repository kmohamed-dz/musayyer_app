import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

const _firebaseSetupError =
    'Firebase is not initialized. Run `flutterfire configure` and ensure Firebase.initializeApp() succeeds.';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _productsCollection() {
    _ensureFirebaseInitialized();
    return FirestorePaths.products(_firestore);
  }

  @override
  Stream<List<Product>> watchProducts() {
    if (!_isFirebaseInitialized) {
      return Stream<List<Product>>.error(StateError(_firebaseSetupError));
    }

    return _productsCollection()
        .orderBy('updatedAtMs', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Product.fromSnapshot).toList());
  }

  @override
  Stream<Product?> watchProductById(String id) {
    if (!_isFirebaseInitialized) {
      return Stream<Product?>.error(StateError(_firebaseSetupError));
    }

    return _productsCollection().doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Product.fromSnapshot(snapshot);
    });
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final query = await _productsCollection()
        .orderBy('updatedAtMs', descending: true)
        .get();
    return query.docs.map(Product.fromSnapshot).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final snapshot = await _productsCollection().doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return Product.fromSnapshot(snapshot);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      return null;
    }

    final query = await _productsCollection()
        .where('barcode', isEqualTo: normalizedBarcode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return Product.fromSnapshot(query.docs.first);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim().toLowerCase();
    final products = await getAllProducts();
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
  }

  @override
  Future<void> upsertProduct(Product product) async {
    await _productsCollection().doc(product.id).set(product.toMap());
  }

  @override
  Future<void> addProduct(Product product) => upsertProduct(product);

  @override
  Future<void> updateProduct(Product product) => upsertProduct(product);

  @override
  Future<void> deleteProduct(String id) async {
    await _productsCollection().doc(id).delete();
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    await _productsCollection().doc(productId).update({
      'stock': newStock,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  void _ensureFirebaseInitialized() {
    if (!_isFirebaseInitialized) {
      throw StateError(_firebaseSetupError);
    }
  }
}
