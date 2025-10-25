import 'package:get/get.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';

class ReminderController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  
  final RxList<Reminder> reminders = <Reminder>[].obs;
  final RxList<Reminder> upcomingReminders = <Reminder>[].obs;
  final RxList<Reminder> overdueReminders = <Reminder>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadRemindersByVehicle(String vehicleId) async {
    try {
      isLoading.value = true;
      reminders.value = _dbService.getRemindersByVehicle(vehicleId);
      upcomingReminders.value = _dbService.getUpcomingReminders(vehicleId);
      overdueReminders.value = _dbService.getOverdueReminders(vehicleId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reminders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      isLoading.value = true;
      await _dbService.addReminder(reminder);
      reminders.add(reminder);
      reminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
      Get.snackbar('Success', 'Reminder added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add reminder: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      isLoading.value = true;
      await _dbService.updateReminder(reminder);
      final index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder;
        reminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
      }
      Get.snackbar('Success', 'Reminder updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update reminder: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      isLoading.value = true;
      await _dbService.deleteReminder(reminderId);
      reminders.removeWhere((r) => r.id == reminderId);
      Get.snackbar('Success', 'Reminder deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete reminder: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleReminderActive(String reminderId) async {
    try {
      final reminder = _dbService.getReminder(reminderId);
      if (reminder != null) {
        reminder.isActive = !reminder.isActive;
        await updateReminder(reminder);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle reminder: $e');
    }
  }

  int get totalReminders => reminders.length;
  int get upcomingCount => upcomingReminders.length;
  int get overdueCount => overdueReminders.length;
}
