import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/expense_controller.dart';
import '../models/vehicle.dart';
import '../models/maintenance_log.dart';
import '../theme/app_theme.dart';
import '../widgets/maintenance_card.dart';

class MaintenanceLogScreen extends StatefulWidget {
  final Vehicle vehicle;

  const MaintenanceLogScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<MaintenanceLogScreen> createState() => _MaintenanceLogScreenState();
}

class _MaintenanceLogScreenState extends State<MaintenanceLogScreen> {
  final maintenanceController = Get.find<MaintenanceController>();
  final expenseController = Get.find<ExpenseController>();
  bool _isAddingLog = false;

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
    maintenanceController.loadMaintenanceLogsByVehicle(widget.vehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Logs'),
        elevation: 0,
      ),
      body: Obx(() {
        if (maintenanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            _isAddingLog
                ? _buildAddMaintenanceForm()
                : _buildMaintenanceList(),
          ],
        );
      }),
      floatingActionButton: !_isAddingLog
          ? FloatingActionButton(
              onPressed: () {
                setState(() => _isAddingLog = true);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMaintenanceList() {
    return Obx(() {
      final logs = maintenanceController.maintenanceLogs;
      
      if (logs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build, size: 64, color: AppTheme.darkGray),
              const SizedBox(height: 16),
              Text(
                'No maintenance logs found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first maintenance record',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MaintenanceCard(
              serviceType: log.serviceType,
              serviceDate: log.serviceDate,
              mileage: log.mileage,
              servicedBy: log.servicedBy,
              cost: log.cost,
              onTap: () => _editMaintenanceLog(log),
              onDelete: () => _deleteMaintenanceLog(log.id),
            ),
          );
        },
      );
    });
  }

  Widget _buildAddMaintenanceForm() {
    final formKey = GlobalKey<FormState>();
    String selectedServiceType = serviceTypes[0];
    DateTime selectedDate = DateTime.now();
    double mileage = 0;
    String servicedBy = '';
    double? cost;
    String description = '';
    String invoiceNumber = '';

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Maintenance Log',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Service Type Dropdown
            _buildDropdownField(
              label: 'Service Type',
              value: selectedServiceType,
              items: serviceTypes,
              onChanged: (value) {
                selectedServiceType = value!;
              },
            ),
            const SizedBox(height: 16),

            // Service Date
            _buildDateField(
              label: 'Service Date',
              date: selectedDate,
              onChanged: (date) {
                selectedDate = date;
              },
            ),
            const SizedBox(height: 16),

            // Mileage
            _buildTextField(
              label: 'Mileage (km)',
              hint: 'e.g., 50000',
              onChanged: (value) {
                mileage = double.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Serviced By
            _buildTextField(
              label: 'Serviced By',
              hint: 'Mechanic name or service center',
              onChanged: (value) {
                servicedBy = value;
              },
            ),
            const SizedBox(height: 16),

            // Cost
            _buildTextField(
              label: 'Cost (\$)',
              hint: 'Optional',
              onChanged: (value) {
                cost = double.tryParse(value);
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              label: 'Description',
              hint: 'Additional details...',
              onChanged: (value) {
                description = value;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Invoice Number
            _buildTextField(
              label: 'Invoice Number',
              hint: 'Optional',
              onChanged: (value) {
                invoiceNumber = value;
              },
            ),
            const SizedBox(height: 32),

            // action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isAddingLog = false);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final log = MaintenanceLog(
                        id: const Uuid().v4(),
                        vehicleId: widget.vehicle.id,
                        serviceType: selectedServiceType,
                        serviceDate: selectedDate,
                        mileage: mileage,
                        servicedBy: servicedBy.isEmpty ? null : servicedBy,
                        cost: cost,
                        description: description.isEmpty ? null : description,
                        invoiceNumber: invoiceNumber.isEmpty ? null : invoiceNumber,
                      );
                      await maintenanceController.addMaintenanceLog(log, widget.vehicle);
                      await expenseController.loadExpensesByVehicle(widget.vehicle.id);
                      setState(() => _isAddingLog = false);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editMaintenanceLog(MaintenanceLog log) {
    // Implementation for edit functionality
  }

  void _deleteMaintenanceLog(String logId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this maintenance log?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              maintenanceController.deleteMaintenanceLog(logId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(hintText: label),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.darkGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(date)),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
