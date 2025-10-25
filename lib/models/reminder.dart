import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 2)
class Reminder {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String vehicleId;

  @HiveField(2)
  late String serviceType; // e.g., Oil Change, Tire Rotation

  @HiveField(3)
  late DateTime reminderDate;

  @HiveField(4)
  late bool isActive;

  @HiveField(5)
  late String? description;

  @HiveField(6)
  late DateTime createdDate;

  @HiveField(7)
  late DateTime? lastNotificationSent;

  @HiveField(8)
  late int? mileageReminder; // optional reminder based on mileage

  Reminder({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.reminderDate,
    this.isActive = true,
    this.description,
    DateTime? createdDate,
    this.lastNotificationSent,
    this.mileageReminder,
  }) : createdDate = createdDate ?? DateTime.now();

  bool get isOverdue => reminderDate.isBefore(DateTime.now()) && isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'serviceType': serviceType,
    'reminderDate': reminderDate.toIso8601String(),
    'isActive': isActive,
    'description': description,
    'createdDate': createdDate.toIso8601String(),
    'lastNotificationSent': lastNotificationSent?.toIso8601String(),
    'mileageReminder': mileageReminder,
  };
}
