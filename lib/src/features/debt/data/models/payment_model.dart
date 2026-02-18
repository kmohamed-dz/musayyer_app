import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 5)
class PaymentModel extends HiveObject {
  PaymentModel({
    required this.id,
    required this.debtId,
    required this.customerId,
    required this.amount,
    required this.paidAt,
    this.notes,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String debtId;

  @HiveField(2)
  late String customerId;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late DateTime paidAt;

  @HiveField(5)
  late String? notes;
}
