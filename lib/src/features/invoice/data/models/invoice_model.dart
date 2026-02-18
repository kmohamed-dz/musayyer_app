import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 1)
class InvoiceModel extends HiveObject {
  InvoiceModel({
    required this.id,
    this.customerId,
    required this.itemIds,
    required this.totalAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.status,
    this.notes,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String? customerId;

  @HiveField(2)
  late List<String> itemIds;

  @HiveField(3)
  late double totalAmount;

  @HiveField(4)
  late double paidAmount;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late String status;

  @HiveField(7)
  late String? notes;
}
