import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle.dart';
import '../models/maintenance_log.dart';
import '../models/reminder.dart';
import '../models/expense.dart';

class DatabaseService {
  static const String vehiclesBox = 'vehicles';
  static const String maintenanceLogsBox = 'maintenance_logs';
  static const String remindersBox = 'reminders';
  static const String expensesBox = 'expenses';
  static const String activeVehicleBox = 'active_vehicle';

  // Vehicle Operations
  Future<void> addVehicle(Vehicle vehicle) async {
    final box = Hive.box<Vehicle>(vehiclesBox);
    await box.put(vehicle.id, vehicle);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final box = Hive.box<Vehicle>(vehiclesBox);
    await box.put(vehicle.id, vehicle);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final box = Hive.box<Vehicle>(vehiclesBox);
    await box.delete(vehicleId);
    
    // Delete related data
    await _deleteVehicleRelatedData(vehicleId);
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    final box = Hive.box<Vehicle>(vehiclesBox);
    return box.get(vehicleId);
  }

  List<Vehicle> getAllVehicles() {
    final box = Hive.box<Vehicle>(vehiclesBox);
    return box.values.toList();
  }

  // Maintenance Log Operations
  Future<void> addMaintenanceLog(MaintenanceLog log) async {
    final box = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    await box.put(log.id, log);
  }

  Future<void> updateMaintenanceLog(MaintenanceLog log) async {
    final box = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    await box.put(log.id, log);
  }

  Future<void> deleteMaintenanceLog(String logId) async {
    final box = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    await box.delete(logId);
  }

  List<MaintenanceLog> getMaintenanceLogsByVehicle(String vehicleId) {
    final box = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    return box.values
        .where((log) => log.vehicleId == vehicleId)
        .toList()
        ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  }

  MaintenanceLog? getMaintenanceLog(String logId) {
    final box = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    return box.get(logId);
  }

  // Reminder Operations
  Future<void> addReminder(Reminder reminder) async {
    final box = Hive.box<Reminder>(remindersBox);
    await box.put(reminder.id, reminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    final box = Hive.box<Reminder>(remindersBox);
    await box.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    final box = Hive.box<Reminder>(remindersBox);
    await box.delete(reminderId);
  }

  List<Reminder> getRemindersByVehicle(String vehicleId) {
    final box = Hive.box<Reminder>(remindersBox);
    return box.values
        .where((reminder) => reminder.vehicleId == vehicleId)
        .toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
  }

  List<Reminder> getUpcomingReminders(String vehicleId) {
    final box = Hive.box<Reminder>(remindersBox);
    final now = DateTime.now();
    return box.values
        .where((reminder) =>
            reminder.vehicleId == vehicleId &&
            reminder.isActive &&
            reminder.reminderDate.isAfter(now))
        .toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
  }

  List<Reminder> getOverdueReminders(String vehicleId) {
    final box = Hive.box<Reminder>(remindersBox);
    return box.values
        .where((reminder) =>
            reminder.vehicleId == vehicleId &&
            reminder.isOverdue)
        .toList();
  }

  Reminder? getReminder(String reminderId) {
    final box = Hive.box<Reminder>(remindersBox);
    return box.get(reminderId);
  }

  // Expense Operations
  Future<void> addExpense(Expense expense) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.put(expense.id, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.delete(expenseId);
  }

  List<Expense> getExpensesByVehicle(String vehicleId) {
    final box = Hive.box<Expense>(expensesBox);
    return box.values
        .where((expense) => expense.vehicleId == vehicleId)
        .toList()
        ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  List<Expense> getExpensesByMaintenanceLog(String maintenanceLogId) {
    final box = Hive.box<Expense>(expensesBox);
    return box.values
        .where((expense) => expense.maintenanceLogId == maintenanceLogId)
        .toList();
  }

  double getTotalExpensesForVehicle(String vehicleId) {
    final box = Hive.box<Expense>(expensesBox);
    return box.values
        .where((expense) => expense.vehicleId == vehicleId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory(String vehicleId) {
    final expenses = getExpensesByVehicle(vehicleId);
    final Map<String, double> categoryExpenses = {};
    
    for (var expense in expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryExpenses;
  }

  Expense? getExpense(String expenseId) {
    final box = Hive.box<Expense>(expensesBox);
    return box.get(expenseId);
  }

  // Helper Methods
  Future<void> _deleteVehicleRelatedData(String vehicleId) async {
    // Delete maintenance logs
    final logsBox = Hive.box<MaintenanceLog>(maintenanceLogsBox);
    final logsToDelete = logsBox.values
        .where((log) => log.vehicleId == vehicleId)
        .map((log) => log.id)
        .toList();
    
    for (var logId in logsToDelete) {
      await logsBox.delete(logId);
    }

    // Delete reminders
    final remindersBox = Hive.box<Reminder>(remindersBox);
    final remindersToDelete = remindersBox.values
        .where((reminder) => reminder.vehicleId == vehicleId)
        .map((reminder) => reminder.id)
        .toList();
    
    for (var reminderId in remindersToDelete) {
      await remindersBox.delete(reminderId);
    }

    // Delete expenses
    final expensesBox = Hive.box<Expense>(expensesBox);
    final expensesToDelete = expensesBox.values
        .where((expense) => expense.vehicleId == vehicleId)
        .map((expense) => expense.id)
        .toList();
    
    for (var expenseId in expensesToDelete) {
      await expensesBox.delete(expenseId);
    }
  }

  String generateId() => const Uuid().v4();
}
