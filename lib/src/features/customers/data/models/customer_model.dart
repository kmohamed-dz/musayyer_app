import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 3)
class CustomerModel extends HiveObject {
  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.totalDebt,
    required this.createdAt,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String? phone;

  @HiveField(3)
  late String? address;

  @HiveField(4)
  late double totalDebt;

  @HiveField(5)
  late DateTime createdAt;
}
