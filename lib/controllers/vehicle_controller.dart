import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class VehicleController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  
  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  void loadVehicles() {
    isLoading.value = true;
    try {
      vehicles.value = _dbService.getAllVehicles();
      if (vehicles.isNotEmpty && selectedVehicle.value == null) {
        selectedVehicle.value = vehicles.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      isLoading.value = true;
      await _dbService.addVehicle(vehicle);
      vehicles.add(vehicle);
      if (selectedVehicle.value == null) {
        selectedVehicle.value = vehicle;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add vehicle: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      isLoading.value = true;
      await _dbService.updateVehicle(vehicle);
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        vehicles[index] = vehicle;
      }
      if (selectedVehicle.value?.id == vehicle.id) {
        selectedVehicle.value = vehicle;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update vehicle: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      isLoading.value = true;
      await _dbService.deleteVehicle(vehicleId);
      vehicles.removeWhere((v) => v.id == vehicleId);
      if (selectedVehicle.value?.id == vehicleId) {
        selectedVehicle.value = vehicles.isNotEmpty ? vehicles.first : null;
      }
      Get.snackbar('Success', 'Vehicle deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete vehicle: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectVehicle(Vehicle vehicle) {
    selectedVehicle.value = vehicle;
  }

  Vehicle? getVehicleById(String id) {
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}
