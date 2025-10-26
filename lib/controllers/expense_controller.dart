import 'package:flutter/material.dart' show debugPrint;
import 'package:get/get.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseController extends GetxController {
  final DatabaseService _dbService = DatabaseService();

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxMap<String, double> expensesByCategory = <String, double>{}.obs;
  final RxBool isLoading = false.obs;

  Future<void> loadExpensesByVehicle(String vehicleId) async {
    try {
      isLoading.value = true;
      final loadedExpenses = _dbService.getExpensesByVehicle(vehicleId);
      debugPrint(
        'Loaded ${loadedExpenses.length} expenses for vehicle $vehicleId',
      );
      expenses.value = loadedExpenses;
      _updateTotals(vehicleId);
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _dbService.addExpense(expense);
      expenses.add(expense);
      expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      _updateTotals(expense.vehicleId);
      Get.snackbar('Success', 'Expense added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(Expense expense, Expense oldExpense) async {
    try {
      isLoading.value = true;
      await _dbService.updateExpense(expense);
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
        expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      }
      _updateTotals(expense.vehicleId);
      Get.snackbar('Success', 'Expense updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      isLoading.value = true;
      final expense = _dbService.getExpense(expenseId);
      if (expense != null) {
        await _dbService.deleteExpense(expenseId);
        expenses.removeWhere((e) => e.id == expenseId);
        _updateTotals(expense.vehicleId);
        Get.snackbar('Success', 'Expense deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateTotals(String vehicleId) {
    final total = _dbService.getTotalExpensesForVehicle(vehicleId);
    debugPrint('Calculated total expenses for vehicle $vehicleId: $total');
    totalExpenses.value = total;

    final categories = _dbService.getExpensesByCategory(vehicleId);
    debugPrint('Categories: $categories');
    expensesByCategory.value = categories;
    expensesByCategory.refresh();
    totalExpenses.refresh();
  }

  double getMonthlyExpenses(int month, int year) {
    return expenses
        .where(
          (e) => e.expenseDate.month == month && e.expenseDate.year == year,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getYearlyExpenses(int year) {
    return expenses
        .where((e) => e.expenseDate.year == year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
