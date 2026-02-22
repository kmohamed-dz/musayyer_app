import 'package:flutter_test/flutter_test.dart';
import 'package:musayyer_app/src/features/inventory/domain/entities/product.dart';
import 'package:musayyer_app/src/features/invoice/domain/entities/invoice.dart';
import 'package:musayyer_app/src/features/invoice/domain/entities/invoice_item.dart';

void main() {
  test('Product toMap/fromMap roundtrip keeps expected fields', () {
    final now = DateTime(2026, 2, 22, 10, 30);
    final product = Product(
      id: 'p1',
      name: 'Rice',
      nameAr: 'Arz',
      nameFr: 'Riz',
      price: 200,
      costPrice: 150,
      stock: 20,
      barcode: '123456',
      category: 'Food',
      imagePath: null,
      unit: 'kg',
      createdAt: now,
      updatedAt: now,
    );

    final map = product.toMap();
    final restored = Product.fromMap(map, id: product.id);

    expect(restored.id, product.id);
    expect(restored.name, product.name);
    expect(restored.barcode, product.barcode);
    expect(restored.stock, product.stock);
    expect(
        restored.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
  });

  test('Invoice toMap/fromMap roundtrip keeps embedded items', () {
    final now = DateTime(2026, 2, 22, 11, 45);
    final items = [
      InvoiceItem(
        id: 'i1',
        productId: 'p1',
        productName: 'Rice',
        unitPrice: 200,
        quantity: 2,
        subtotal: 400,
      ),
    ];

    final invoice = Invoice(
      id: 'inv1',
      customerId: 'c1',
      itemIds: items.map((e) => e.id).toList(),
      items: items,
      totalAmount: 400,
      paidAmount: 100,
      createdAt: now,
      status: 'partial',
      notes: 'test',
    );

    final map = invoice.toMap();
    final restored = Invoice.fromMap(map, id: invoice.id);

    expect(restored.id, invoice.id);
    expect(restored.customerId, invoice.customerId);
    expect(restored.itemIds, invoice.itemIds);
    expect(restored.items.length, 1);
    expect(restored.items.first.productId, 'p1');
    expect(restored.status, 'partial');
    expect(
        restored.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
  });
}
