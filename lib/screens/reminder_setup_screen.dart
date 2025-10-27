import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../controllers/reminder_controller.dart';
import '../models/vehicle.dart';
import '../models/reminder.dart';
import '../theme/app_theme.dart';
import '../widgets/reminder_card.dart';

class ReminderSetupScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ReminderSetupScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> with SingleTickerProviderStateMixin {
  final reminderController = Get.find<ReminderController>();
  late TabController _tabController;
  bool _isAddingReminder = false;

  final List<String> serviceTypes = [
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    reminderController.loadRemindersByVehicle(widget.vehicle.id);
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
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Overdue', icon: Icon(Icons.warning_amber)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingReminders(),
              _buildOverdueReminders(),
              _buildAllReminders(),
            ],
          ),
          if (_isAddingReminder)
            Container(
              color: Colors.black87,
              child: _buildAddReminderForm(),
            ),
        ],
      ),
      floatingActionButton: !_isAddingReminder
          ? FloatingActionButton(
              onPressed: () {
                setState(() => _isAddingReminder = true);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUpcomingReminders() {
    return Obx(() {
      final reminders = reminderController.upcomingReminders;
      return _buildRemindersList(reminders, 'No upcoming reminders');
    });
  }

  Widget _buildOverdueReminders() {
    return Obx(() {
      final reminders = reminderController.overdueReminders;
      return _buildRemindersList(reminders, 'No overdue reminders');
    });
  }

  Widget _buildAllReminders() {
    return Obx(() {
      final reminders = reminderController.reminders;
      return _buildRemindersList(reminders, 'No reminders found');
    });
  }

  Widget _buildRemindersList(List<Reminder> reminders, String emptyMessage) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppTheme.darkGray),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ReminderCard(
            serviceType: reminder.serviceType,
            reminderDate: reminder.reminderDate,
            isActive: reminder.isActive,
            isOverdue: reminder.isOverdue,
            onTap: () => _editReminder(reminder),
            onToggle: (value) {
              reminderController.toggleReminderActive(reminder.id);
            },
            onDelete: () => _deleteReminder(reminder.id),
          ),
        );
      },
    );
  }

  Widget _buildAddReminderForm() {
    String selectedServiceType = serviceTypes[0];
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    String description = '';
    int? mileageReminder;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Reminder',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 24),

          // Service Type
          Text(
            'Service Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryGreen),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedServiceType,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: AppTheme.primaryBlack,
              items: serviceTypes.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: AppTheme.primaryWhite),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedServiceType = value;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Reminder Date
          Text(
            'Reminder Date',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryGreen),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: const TextStyle(color: AppTheme.primaryWhite),
                  ),
                  const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mileage Reminder - need to check further
          Text(
            'Mileage Reminder (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 10000 km',
              hintStyle: TextStyle(color: AppTheme.darkGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryGreen),
              ),
            ),
            onChanged: (value) {
              mileageReminder = int.tryParse(value);
            },
          ),
          const SizedBox(height: 16),

          // description
          Text(
            'Description (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.black),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Additional details...',
              hintStyle: TextStyle(color: AppTheme.darkGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryGreen),
              ),
            ),
            onChanged: (value) {
              description = value;
            },
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _isAddingReminder = false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final reminder = Reminder(
                      id: const Uuid().v4(),
                      vehicleId: widget.vehicle.id,
                      serviceType: selectedServiceType,
                      reminderDate: selectedDate,
                      description: description.isEmpty ? null : description,
                      mileageReminder: mileageReminder,
                    );
                    reminderController.addReminder(reminder);
                    setState(() => _isAddingReminder = false);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    Get.snackbar('Info', 'Edit functionality coming soon');
  }

  void _deleteReminder(String reminderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              reminderController.deleteReminder(reminderId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}
