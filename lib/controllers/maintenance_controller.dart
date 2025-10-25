import 'package:get/get.dart';
import '../models/maintenance_log.dart';
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

  Future<void> addMaintenanceLog(MaintenanceLog log) async {
    try {
      isLoading.value = true;
      await _dbService.addMaintenanceLog(log);
      maintenanceLogs.add(log);
      maintenanceLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      Get.snackbar('Success', 'Maintenance log added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add maintenance log: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMaintenanceLog(MaintenanceLog log) async {
    try {
      isLoading.value = true;
      await _dbService.updateMaintenanceLog(log);
      final index = maintenanceLogs.indexWhere((m) => m.id == log.id);
      if (index != -1) {
        maintenanceLogs[index] = log;
        maintenanceLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
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
