import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';

extension InvoiceModelMapper on InvoiceModel {
  Invoice toEntity() {
    return Invoice(
      id: id,
      customerId: customerId,
      itemIds: itemIds,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      createdAt: createdAt,
      status: status,
      notes: notes,
    );
  }
}

extension InvoiceEntityMapper on Invoice {
  InvoiceModel toModel() {
    return InvoiceModel(
      id: id,
      customerId: customerId,
      itemIds: itemIds,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      createdAt: createdAt,
      status: status,
      notes: notes,
    );
  }
}

extension InvoiceItemModelMapper on InvoiceItemModel {
  InvoiceItem toEntity() {
    return InvoiceItem(
      id: id,
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      quantity: quantity,
      subtotal: subtotal,
    );
  }
}

class HiveInvoiceRepository implements InvoiceRepository {
  HiveInvoiceRepository(
    this._invoiceBox,
    this._itemBox,
    this._customerBox,
  );

  final Box<InvoiceModel> _invoiceBox;
  final Box<InvoiceItemModel> _itemBox;
  final Box<CustomerModel> _customerBox;

  factory HiveInvoiceRepository.fromHive() {
    return HiveInvoiceRepository(
      Hive.box<InvoiceModel>(HiveBoxes.invoices),
      Hive.box<InvoiceItemModel>(HiveBoxes.invoiceItems),
      Hive.box<CustomerModel>(HiveBoxes.customers),
    );
  }

  @override
  Stream<List<Invoice>> watchInvoices() async* {
    yield await getAllInvoices();
    yield* _invoiceBox.watch().asyncMap((_) => getAllInvoices());
  }

  @override
  Stream<Invoice?> watchInvoiceById(String id) async* {
    yield await getInvoiceById(id);
    yield* _invoiceBox
        .watch(key: id)
        .map((_) => _invoiceBox.get(id)?.toEntity());
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final invoices =
        _invoiceBox.values.map((model) => model.toEntity()).toList();
    invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return invoices;
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    return _invoiceBox.get(id)?.toEntity();
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    final invoice = _invoiceBox.get(invoiceId);
    if (invoice == null) {
      return [];
    }

    return invoice.itemIds
        .map((id) => _itemBox.get(id))
        .whereType<InvoiceItemModel>()
        .map((item) => item.toEntity())
        .toList();
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

      final customerName = invoice.customerId == null
          ? ''
          : (_customerBox.get(invoice.customerId)?.name.toLowerCase() ?? '');

      return invoice.id.toLowerCase().contains(normalizedQuery) ||
          customerName.contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<void> createInvoice(Invoice invoice) async {
    for (final item in invoice.items) {
      final model = InvoiceItemModel(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
        subtotal: item.subtotal,
      );
      await _itemBox.put(model.id, model);
    }
    await _invoiceBox.put(invoice.id, invoice.toModel());
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoiceBox.put(invoice.id, invoice.toModel());
  }
}
