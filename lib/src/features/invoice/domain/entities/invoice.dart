import 'package:cloud_firestore/cloud_firestore.dart';

import 'invoice_item.dart';

class Invoice {
  Invoice({
    required this.id,
    this.customerId,
    required this.itemIds,
    List<InvoiceItem>? items,
    required this.totalAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.status,
    this.notes,
  }) : items = List.unmodifiable(items ?? const <InvoiceItem>[]);

  final String id;
  final String? customerId;
  final List<String> itemIds;
  final List<InvoiceItem> items;
  final double totalAmount;
  final double paidAmount;
  final DateTime createdAt;
  final String status;
  final String? notes;

  double get remainingAmount => totalAmount - paidAmount;

  Invoice copyWith({
    String? id,
    String? customerId,
    List<String>? itemIds,
    List<InvoiceItem>? items,
    double? totalAmount,
    double? paidAmount,
    DateTime? createdAt,
    String? status,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      itemIds: itemIds ?? this.itemIds,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'itemIds': itemIds,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'createdAtMs': createdAt.millisecondsSinceEpoch,
      'status': status,
      'notes': notes,
    };
  }

  factory Invoice.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final rawItems = map['items'];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => InvoiceItem.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : <InvoiceItem>[];
    final parsedItemIds = _toStringList(map['itemIds']);
    final itemIds = parsedItemIds.isNotEmpty
        ? parsedItemIds
        : parsedItems
            .map((item) => item.id)
            .where((itemId) => itemId.isNotEmpty)
            .toList();
    final now = DateTime.now();

    return Invoice(
      id: id,
      customerId: map['customerId'] as String?,
      itemIds: itemIds,
      items: parsedItems,
      totalAmount: _toDouble(map['totalAmount']),
      paidAmount: _toDouble(map['paidAmount']),
      createdAt: _toDateTime(map['createdAtMs'], fallback: now),
      status: (map['status'] as String?) ?? 'unpaid',
      notes: map['notes'] as String?,
    );
  }

  factory Invoice.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return Invoice.fromMap(data, id: snapshot.id);
  }
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return <String>[];
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

DateTime _toDateTime(
  dynamic value, {
  required DateTime fallback,
}) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? fallback;
  }
  return fallback;
}
