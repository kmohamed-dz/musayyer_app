import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 4)
class DebtModel extends HiveObject {
  DebtModel({
    required this.id,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.remainingAmount,
    required this.createdAt,
    required this.status,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String customerId;

  @HiveField(2)
  late String? invoiceId;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late double remainingAmount;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late String status;
}
