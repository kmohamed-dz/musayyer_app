import 'package:hive/hive.dart';

part 'invoice_item_model.g.dart';

@HiveType(typeId: 2)
class InvoiceItemModel extends HiveObject {
  InvoiceItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productId;

  @HiveField(2)
  late String productName;

  @HiveField(3)
  late double unitPrice;

  @HiveField(4)
  late int quantity;

  @HiveField(5)
  late double subtotal;
}
