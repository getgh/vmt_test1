import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/vehicle.dart';
import 'models/maintenance_log.dart';
import 'models/reminder.dart';
import 'models/expense.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(MaintenanceLogAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  
  // Open boxes
  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<MaintenanceLog>('maintenance_logs');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox<Expense>('expenses');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
