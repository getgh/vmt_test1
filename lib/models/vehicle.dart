import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String make; // e.g., Toyota

  @HiveField(2)
  late String model; // e.g., Camry

  @HiveField(3)
  late int year;

  @HiveField(4)
  late double currentMileage;

  @HiveField(5)
  late String licensePlate;

  @HiveField(6)
  late DateTime createdDate;

  @HiveField(7)
  late DateTime lastUpdated;

  @HiveField(8)
  late String? notes;

  @HiveField(9)
  late String? color;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.currentMileage,
    required this.licensePlate,
    DateTime? createdDate,
    DateTime? lastUpdated,
    this.notes,
    this.color,
  })  : createdDate = createdDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  String get displayName => '$year $make $model';

  void updateMileage(double newMileage) {
    currentMileage = newMileage;
    lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'make': make,
    'model': model,
    'year': year,
    'currentMileage': currentMileage,
    'licensePlate': licensePlate,
    'createdDate': createdDate.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'notes': notes,
    'color': color,
  };
}
