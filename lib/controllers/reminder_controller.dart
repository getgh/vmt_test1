import 'package:flutter/material.dart' show debugPrint;
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
    if (vehicleId.isEmpty) {
      reminders.value = [];
      upcomingReminders.value = [];
      overdueReminders.value = [];
      return;
    }

    try {
      isLoading.value = true;
      final allReminders = _dbService.getRemindersByVehicle(vehicleId);
      reminders.value = allReminders;

      // Calculate upcoming and overdue
      final now = DateTime.now();
      upcomingReminders.value =
          allReminders
              .where(
                (reminder) =>
                    reminder.isActive && reminder.reminderDate.isAfter(now),
              )
              .toList()
            ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

      overdueReminders.value = allReminders
          .where((reminder) => reminder.isOverdue)
          .toList();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      reminders.value = [];
      upcomingReminders.value = [];
      overdueReminders.value = [];
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
      _updateReminderLists();
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
      _updateReminderLists();
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
      _updateReminderLists();
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
        await _dbService.updateReminder(reminder);
        final index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          reminders[index] = reminder;
        }
        _updateReminderLists();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle reminder: $e');
    }
  }

  void _updateReminderLists() {
    // Update upcoming reminders
    final now = DateTime.now();
    upcomingReminders.value =
        reminders
            .where(
              (reminder) =>
                  reminder.isActive && reminder.reminderDate.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    // Update overdue reminders
    overdueReminders.value = reminders
        .where((reminder) => reminder.isOverdue)
        .toList();
  }

  int get totalReminders => reminders.length;
  int get upcomingCount => upcomingReminders.length;
  int get overdueCount => overdueReminders.length;
}
