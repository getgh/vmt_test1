import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
class Expense {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String vehicleId;

  @HiveField(2)
  late String maintenanceLogId;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String category; // e.g., Oil Change, Repair, Parts, Labor

  @HiveField(5)
  late DateTime expenseDate;

  @HiveField(6)
  late String? paymentMethod; // e.g., Cash, Card, Check

  @HiveField(7)
  late String? notes;

  @HiveField(8)
  late DateTime createdDate;

  Expense({
    required this.id,
    required this.vehicleId,
    required this.maintenanceLogId,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.paymentMethod,
    this.notes,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'maintenanceLogId': maintenanceLogId,
    'amount': amount,
    'category': category,
    'expenseDate': expenseDate.toIso8601String(),
    'paymentMethod': paymentMethod,
    'notes': notes,
    'createdDate': createdDate.toIso8601String(),
  };
}
