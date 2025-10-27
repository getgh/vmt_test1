class AppConstants {
  // App Name
  static const String appName = 'Vehicle Maintenance Tracker';
  
  // API timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Database
  static const String vehiclesBoxName = 'vehicles';
  static const String maintenanceLogsBoxName = 'maintenance_logs';
  static const String remindersBoxName = 'reminders';
  static const String expensesBoxName = 'expenses';
  
  // Service Types
  static const List<String> serviceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Inspection',
    'Brake Service',
    'Battery Replacement',
    'Filter Replacement',
    'Fluid Top-up',
    'Alignment',
    'Other',
  ];
  
  // Expense Categories
  static const List<String> expenseCategories = [
    'Oil Change',
    'Repair',
    'Parts',
    'Labor',
    'Inspection',
    'Other',
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'Check',
    'Bank Transfer',
    'Other',
  ];
}
