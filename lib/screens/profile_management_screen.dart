import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_info_screen.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final vehicleController = Get.find<VehicleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
      ),
      body: Obx(() {
        final vehicles = vehicleController.vehicles;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Your Vehicles',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Total Vehicles: ${vehicles.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 24),

              if (vehicles.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 80,
                        color: AppTheme.darkGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vehicles added yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first vehicle to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => const VehicleInfoScreen()),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vehicle'),
                      ),
                    ],
                  ),
                )
              else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: VehicleCard(
                        make: vehicle.make,
                        model: vehicle.model,
                        year: vehicle.year,
                        mileage: vehicle.currentMileage,
                        licensePlate: vehicle.licensePlate,
                        onTap: () {
                          vehicleController.selectVehicle(vehicle);
                          Get.back();
                        },
                        onDelete: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Delete Vehicle'),
                              content: Text(
                                'Are you sure you want to delete ${vehicle.displayName}? This will also delete all maintenance logs, reminders, and expenses associated with this vehicle.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    vehicleController.deleteVehicle(vehicle.id);
                                    Get.back();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: AppTheme.primaryRed),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const VehicleInfoScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
