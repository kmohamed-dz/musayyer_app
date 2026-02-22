import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceItem {
  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: (map['id'] as String?) ?? '',
      productId: (map['productId'] as String?) ?? '',
      productName: (map['productName'] as String?) ?? '',
      unitPrice: _toDouble(map['unitPrice']),
      quantity: _toInt(map['quantity']),
      subtotal: _toDouble(map['subtotal']),
    );
  }

  factory InvoiceItem.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return InvoiceItem.fromMap({
      ...data,
      'id': snapshot.id,
    });
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
