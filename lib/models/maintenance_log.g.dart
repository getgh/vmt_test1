// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceLogAdapter extends TypeAdapter<MaintenanceLog> {
  @override
  final int typeId = 1;

  @override
  MaintenanceLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceLog(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      serviceType: fields[2] as String,
      serviceDate: fields[3] as DateTime,
      mileage: fields[4] as double,
      description: fields[5] as String?,
      servicedBy: fields[6] as String?,
      createdDate: fields[7] as DateTime?,
      cost: fields[8] as double?,
      invoiceNumber: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.serviceType)
      ..writeByte(3)
      ..write(obj.serviceDate)
      ..writeByte(4)
      ..write(obj.mileage)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.servicedBy)
      ..writeByte(7)
      ..write(obj.createdDate)
      ..writeByte(8)
      ..write(obj.cost)
      ..writeByte(9)
      ..write(obj.invoiceNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
