import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle_maintenance_tracker/constants/app_constants.dart';
import 'models/vehicle.dart';
import 'models/maintenance_log.dart';
import 'models/reminder.dart';
import 'models/expense.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(MaintenanceLogAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Vehicle>(AppConstants.vehiclesBoxName);
  await Hive.openBox<MaintenanceLog>(AppConstants.maintenanceLogsBoxName);
  await Hive.openBox<Reminder>(AppConstants.remindersBoxName);
  await Hive.openBox<Expense>(AppConstants.expensesBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vehicle Maintenance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
