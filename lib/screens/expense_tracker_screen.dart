import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/expense_controller.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_card.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ExpenseTrackerScreen({super.key, required this.vehicle});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen>
    with SingleTickerProviderStateMixin {
  final expenseController = Get.find<ExpenseController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    expenseController.loadExpensesByVehicle(widget.vehicle.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.bar_chart)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Expenses Card
          _buildTotalExpensesCard(),
          const SizedBox(height: 24),

          _buildCategoryBreakdown(),
          const SizedBox(height: 24),

          _buildMonthlyExpensesChart(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      final expenses = expenseController.expenses;

      if (expenses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_outlined, size: 64, color: AppTheme.darkGray),
              const SizedBox(height: 16),
              Text(
                'No expenses recorded',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseCard(
              category: expense.category,
              amount: expense.amount,
              expenseDate: expense.expenseDate,
              paymentMethod: expense.paymentMethod,
              onTap: () {},
              onDelete: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text(
                      'Are you sure you want to delete this expense?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          expenseController.deleteExpense(expense.id);
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
      );
    });
  }

  Widget _buildTotalExpensesCard() {
    return Obx(() {
      final total = expenseController.totalExpenses.value;
      return Card(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryWhite.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total maintenance expenses for ${widget.vehicle.displayName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryWhite.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryBreakdown() {
    return Obx(() {
      final categories = expenseController.expensesByCategory;

      if (categories.isEmpty) {
        return const SizedBox();
      }

      final totalExpenses = expenseController.totalExpenses.value;
      final pieChartSections = categories.entries.map((entry) {
        final percentage = (entry.value / totalExpenses) * 100;
        final colors = [
          AppTheme.primaryRed,
          AppTheme.primaryGreen,
          AppTheme.primaryBlack,
          AppTheme.darkGray,
        ];
        final colorIndex =
            categories.keys.toList().indexOf(entry.key) % colors.length;

        return PieChartSectionData(
          color: colors[colorIndex],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryWhite,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(sections: pieChartSections)),
                  ),
                  const SizedBox(height: 24),
                  ...categories.entries.map((entry) {
                    final colors = [
                      AppTheme.primaryRed,
                      AppTheme.primaryGreen,
                      AppTheme.primaryBlack,
                      AppTheme.darkGray,
                    ];
                    final colorIndex =
                        categories.keys.toList().indexOf(entry.key) %
                        colors.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: colors[colorIndex],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            '\$${entry.value.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colors[colorIndex],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMonthlyExpensesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Expenses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMonthlyBarChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBarChart() {
    final now = DateTime.now();
    final monthlyData = <BarChartGroupData>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final amount = expenseController.getMonthlyExpenses(
        date.month,
        date.year,
      );

      monthlyData.add(
        BarChartGroupData(
          x: 5 - i,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: AppTheme.primaryGreen,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: monthlyData,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  final index = value.toInt();
                  if (index >= 0 && index < monthNames.length) {
                    return Text(monthNames[index]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text('\$${value.toInt()}');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
