import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/maintenance_log.dart';
import '../models/vehicle.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class MaintenanceController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  
  final RxList<MaintenanceLog> maintenanceLogs = <MaintenanceLog>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadMaintenanceLogsByVehicle(String vehicleId) async {
    try {
      isLoading.value = true;
      maintenanceLogs.value = _dbService.getMaintenanceLogsByVehicle(vehicleId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load maintenance logs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMaintenanceLog(MaintenanceLog log, Vehicle vehicle) async {
    try {
      isLoading.value = true;
      await _dbService.addMaintenanceLog(log);
      maintenanceLogs.add(log);
      maintenanceLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      
      // Create an expense if cost is provided
      if (log.cost != null && log.cost! > 0) {
        final expense = Expense(
          id: const Uuid().v4(),
          vehicleId: log.vehicleId,
          maintenanceLogId: log.id,
          amount: log.cost!,
          category: log.serviceType,
          expenseDate: log.serviceDate,
          notes: log.description,
        );
        await _dbService.addExpense(expense);
        print('Created expense for maintenance log: ${expense.amount}');
      }
      
      // Update vehicle mileage if the new mileage is higher
      if (log.mileage > vehicle.currentMileage) {
        vehicle.currentMileage = log.mileage;
        await _dbService.updateVehicle(vehicle);
      }
      
      Get.snackbar('Success', 'Maintenance log added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add maintenance log: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMaintenanceLog(MaintenanceLog log, Vehicle vehicle) async {
    try {
      isLoading.value = true;
      await _dbService.updateMaintenanceLog(log);
      final index = maintenanceLogs.indexWhere((m) => m.id == log.id);
      if (index != -1) {
        maintenanceLogs[index] = log;
        maintenanceLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      }
      
      // Update vehicle mileage if the new mileage is higher
      if (log.mileage > vehicle.currentMileage) {
        vehicle.currentMileage = log.mileage;
        await _dbService.updateVehicle(vehicle);
      }
      
      Get.snackbar('Success', 'Maintenance log updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update maintenance log: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMaintenanceLog(String logId) async {
    try {
      isLoading.value = true;
      await _dbService.deleteMaintenanceLog(logId);
      maintenanceLogs.removeWhere((m) => m.id == logId);
      Get.snackbar('Success', 'Maintenance log deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete maintenance log: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<MaintenanceLog> getMaintenanceLogsByType(String vehicleId, String serviceType) {
    return _dbService.getMaintenanceLogsByVehicle(vehicleId)
        .where((log) => log.serviceType == serviceType)
        .toList();
  }

  MaintenanceLog? getLastMaintenanceLog(String vehicleId, String serviceType) {
    final logs = getMaintenanceLogsByType(vehicleId, serviceType);
    return logs.isNotEmpty ? logs.first : null;
  }
}
