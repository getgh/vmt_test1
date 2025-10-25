import 'package:hive/hive.dart';

part 'maintenance_log.g.dart';

@HiveType(typeId: 1)
class MaintenanceLog {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String vehicleId;

  @HiveField(2)
  late String serviceType; // e.g., Oil Change, Tire Rotation, Inspection

  @HiveField(3)
  late DateTime serviceDate;

  @HiveField(4)
  late double mileage;

  @HiveField(5)
  late String? description;

  @HiveField(6)
  late String? servicedBy; // mechanic name or service center

  @HiveField(7)
  late DateTime createdDate;

  @HiveField(8)
  late double? cost;

  @HiveField(9)
  late String? invoiceNumber;

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.serviceDate,
    required this.mileage,
    this.description,
    this.servicedBy,
    DateTime? createdDate,
    this.cost,
    this.invoiceNumber,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'serviceType': serviceType,
    'serviceDate': serviceDate.toIso8601String(),
    'mileage': mileage,
    'description': description,
    'servicedBy': servicedBy,
    'createdDate': createdDate.toIso8601String(),
    'cost': cost,
    'invoiceNumber': invoiceNumber,
  };
}
