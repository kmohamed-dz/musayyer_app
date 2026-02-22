import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';

const _firebaseSetupError =
    'Firebase is not initialized. Run `flutterfire configure` and ensure Firebase.initializeApp() succeeds.';

class FirestoreInvoiceRepository implements InvoiceRepository {
  FirestoreInvoiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _invoicesCollection() {
    _ensureFirebaseInitialized();
    return FirestorePaths.invoices(_firestore);
  }

  CollectionReference<Map<String, dynamic>> _productsCollection() {
    _ensureFirebaseInitialized();
    return FirestorePaths.products(_firestore);
  }

  @override
  Stream<List<Invoice>> watchInvoices() {
    if (!_isFirebaseInitialized) {
      return Stream<List<Invoice>>.error(StateError(_firebaseSetupError));
    }

    return _invoicesCollection()
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Invoice.fromSnapshot).toList());
  }

  @override
  Stream<Invoice?> watchInvoiceById(String id) {
    if (!_isFirebaseInitialized) {
      return Stream<Invoice?>.error(StateError(_firebaseSetupError));
    }

    return _invoicesCollection().doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Invoice.fromSnapshot(snapshot);
    });
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final query = await _invoicesCollection()
        .orderBy('createdAtMs', descending: true)
        .get();
    return query.docs.map(Invoice.fromSnapshot).toList();
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    final snapshot = await _invoicesCollection().doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return Invoice.fromSnapshot(snapshot);
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    final invoice = await getInvoiceById(invoiceId);
    return invoice?.items ?? const <InvoiceItem>[];
  }

  @override
  Future<List<Invoice>> searchInvoices({
    required String query,
    required String status,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedStatus = status.toLowerCase();
    final invoices = await getAllInvoices();

    return invoices.where((invoice) {
      final matchesStatus =
          normalizedStatus == 'all' || invoice.status == normalizedStatus;
      if (!matchesStatus) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return invoice.id.toLowerCase().contains(normalizedQuery) ||
          (invoice.customerId?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();
  }

  @override
  Future<void> createInvoice(Invoice invoice) async {
    if (invoice.items.isEmpty) {
      throw StateError('Cannot create an invoice with no items.');
    }

    final quantitiesByProduct = <String, int>{};
    for (final item in invoice.items) {
      quantitiesByProduct.update(
        item.productId,
        (value) => value + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }

    final products = _productsCollection();
    final invoices = _invoicesCollection();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await _firestore.runTransaction((transaction) async {
      final productSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final entry in quantitiesByProduct.entries) {
        final productRef = products.doc(entry.key);
        final snapshot = await transaction.get(productRef);
        if (!snapshot.exists) {
          throw StateError('Product not found: ${entry.key}');
        }

        final availableStock = _toInt(snapshot.data()?['stock']);
        if (availableStock < entry.value) {
          throw StateError('Insufficient stock for product: ${entry.key}');
        }

        productSnapshots[entry.key] = snapshot;
      }

      for (final entry in quantitiesByProduct.entries) {
        final snapshot = productSnapshots[entry.key]!;
        final currentStock = _toInt(snapshot.data()?['stock']);
        final newStock = currentStock - entry.value;
        transaction.update(snapshot.reference, {
          'stock': newStock,
          'updatedAtMs': nowMs,
        });
      }

      transaction.set(invoices.doc(invoice.id), invoice.toMap());
    });
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoicesCollection().doc(invoice.id).set(
          invoice.toMap(),
          SetOptions(merge: true),
        );
  }

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  void _ensureFirebaseInitialized() {
    if (!_isFirebaseInitialized) {
      throw StateError(_firebaseSetupError);
    }
  }
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
