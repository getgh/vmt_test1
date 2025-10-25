import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/reminder_controller.dart';
import '../controllers/expense_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/reminder_card.dart';
import 'vehicle_info_screen.dart';
import 'maintenance_log_screen.dart';
import 'profile_management_screen.dart';
import 'reminder_setup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final vehicleController = Get.put(VehicleController());
  final maintenanceController = Get.put(MaintenanceController());
  final reminderController = Get.put(ReminderController());
  final expenseController = Get.put(ExpenseController());

  @override
  void initState() {
    super.initState();
    // Defer loading to next frame to ensure selectedVehicle is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboard();
      
      // Listen for vehicle changes
      vehicleController.selectedVehicle.listen((vehicle) {
        if (vehicle != null) {
          print('Vehicle changed to ${vehicle.id}, refreshing expenses');
          expenseController.loadExpensesByVehicle(vehicle.id);
        }
      });
    });
  }

  void _refreshDashboard() async {
    final vehicleId = vehicleController.selectedVehicle.value?.id;
    if (vehicleId != null) {
      await maintenanceController.loadMaintenanceLogsByVehicle(vehicleId);
      await reminderController.loadRemindersByVehicle(vehicleId);
      await expenseController.loadExpensesByVehicle(vehicleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Maintenance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Get.to(() => const ProfileManagementScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),
        ],
      ),
      body: Obx(() {
        if (vehicleController.selectedVehicle.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: AppTheme.darkGray),
                const SizedBox(height: 16),
                Text(
                  'No vehicles found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.to(() => const ProfileManagementScreen()),
                  child: const Text('Add a Vehicle'),
                ),
              ],
            ),
          );
        }

        final vehicle = vehicleController.selectedVehicle.value!;

        return RefreshIndicator(
          onRefresh: () async {
            _refreshDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: vehicleController.vehicles.map((v) {
                      final isSelected = v.id == vehicle.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${v.year} ${v.make}'),
                          selected: isSelected,
                          onSelected: (_) {
                            vehicleController.selectVehicle(v);
                            _refreshDashboard();
                          },
                          backgroundColor: AppTheme.lightGray,
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryWhite : AppTheme.primaryBlack,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Vehicle Card
                GestureDetector(
                  onTap: () => Get.to(
                    () => VehicleInfoScreen(vehicle: vehicle),
                    transition: Transition.rightToLeft,
                  ),
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlack, AppTheme.primaryBlack.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.primaryWhite,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'License Plate',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryWhite.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    vehicle.licensePlate,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primaryWhite,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Current Mileage',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryWhite.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${vehicle.currentMileage.toStringAsFixed(0)} km',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming Reminders Section
                _buildSection(
                  context,
                  title: 'Upcoming Reminders',
                  icon: Icons.calendar_today,
                  count: reminderController.upcomingReminders.length,
                  onViewAll: () => Get.to(() => ReminderScreen(vehicle: vehicle)),
                  child: Obx(() {
                    final reminders = reminderController.upcomingReminders.take(3).toList();
                    if (reminders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No upcoming reminders',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: reminders.map((reminder) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ReminderCard(
                            serviceType: reminder.serviceType,
                            reminderDate: reminder.reminderDate,
                            isActive: reminder.isActive,
                            isOverdue: reminder.isOverdue,
                            onTap: () {},
                            onToggle: (value) {
                              reminderController.toggleReminderActive(reminder.id);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Recent Maintenance Section
                _buildSection(
                  context,
                  title: 'Recent Maintenance',
                  icon: Icons.build,
                  count: maintenanceController.maintenanceLogs.length,
                  onViewAll: () => Get.to(
                    () => MaintenanceLogScreen(vehicle: vehicle),
                    transition: Transition.rightToLeft,
                  ),
                  child: Obx(() {
                    final logs = maintenanceController.maintenanceLogs.take(3).toList();
                    if (logs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No maintenance logs',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: logs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MaintenanceCard(
                            serviceType: log.serviceType,
                            serviceDate: log.serviceDate,
                            mileage: log.mileage,
                            servicedBy: log.servicedBy,
                            cost: log.cost,
                            onTap: () {},
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Expenses Summary Section
                _buildExpensesSummary(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (vehicleController.selectedVehicle.value == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Get.to(
            () => MaintenanceLogScreen(vehicle: vehicleController.selectedVehicle.value!),
            transition: Transition.rightToLeft,
          ),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required VoidCallback onViewAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildExpensesSummary(BuildContext context) {
    return Obx(() {
      final total = expenseController.totalExpenses.value;
      return Card(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryGreen, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Total Expenses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total maintenance expenses tracked',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ReminderScreen extends StatelessWidget {
  final dynamic vehicle;
  const ReminderScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReminderSetupScreen(vehicle: vehicle);
  }
}
