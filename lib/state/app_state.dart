import 'package:flutter/material.dart';

import '../models/invoice.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  bool scanMode = true;
  final List<Product> _products = [];
  final List<Invoice> _invoices = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  Future<void> upsertProduct(Product product) async {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      _products.add(product);
    } else {
      _products[index] = product;
    }
    _products.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Product? findProductByBarcode(String barcode) {
    try {
      return _products.firstWhere(
        (item) => item.barcode.trim() == barcode.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> createInvoice(List<InvoiceItem> items) async {
    final total = items.fold(0.0, (sum, item) => sum + item.qty * item.price);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final invoice = Invoice(
      id: nowMs.toString(),
      createdAtMs: nowMs,
      items: items,
      total: total,
    );
    _invoices.insert(0, invoice);

    for (final item in items) {
      final index = _products.indexWhere((product) => product.id == item.productId);
      if (index == -1) continue;
      final product = _products[index];
      final newQty = (product.quantity - item.qty).clamp(0, double.infinity);
      _products[index] = product.copyWith(quantity: newQty);
    }

    notifyListeners();
  }
}
