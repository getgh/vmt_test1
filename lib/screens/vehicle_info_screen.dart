import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleInfoScreen({super.key, this.vehicle});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _colorController;
  late final TextEditingController _notesController;

  final vehicleController = Get.find<VehicleController>();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.vehicle == null;
    _initializeControllers();
  }

  void _initializeControllers() {
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _mileageController = TextEditingController(
      text: widget.vehicle?.currentMileage.toString() ?? '',
    );
    _licensePlateController = TextEditingController(
      text: widget.vehicle?.licensePlate ?? '',
    );
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _notesController = TextEditingController(text: widget.vehicle?.notes ?? '');
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_makeController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _licensePlateController.text.isEmpty ||
        _mileageController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all required fields');
      return;
    }

    try {
      final year = int.parse(_yearController.text);
      final mileage = double.parse(_mileageController.text);

      if (widget.vehicle == null) {
        // Create new vehicle
        final newVehicle = Vehicle(
          id: const Uuid().v4(),
          make: _makeController.text,
          model: _modelController.text,
          year: year,
          currentMileage: mileage,
          licensePlate: _licensePlateController.text,
          color: _colorController.text,
          notes: _notesController.text,
        );
        vehicleController.addVehicle(newVehicle);
      } else {
        // Update existing vehicle
        widget.vehicle!.make = _makeController.text;
        widget.vehicle!.model = _modelController.text;
        widget.vehicle!.year = year;
        widget.vehicle!.currentMileage = mileage;
        widget.vehicle!.licensePlate = _licensePlateController.text;
        widget.vehicle!.color = _colorController.text;
        widget.vehicle!.notes = _notesController.text;
        vehicleController.updateVehicle(widget.vehicle!);
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Invalid input: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Add Vehicle' : 'Vehicle Details'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _makeController,
              label: 'Make',
              hint: 'e.g., Toyota',
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _modelController,
              label: 'Model',
              hint: 'e.g., Camry',
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _yearController,
              label: 'Year',
              hint: 'e.g., 2022',
              enabled: isEditing,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              hint: 'e.g., ABC-1234',
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _mileageController,
              label: 'Current Mileage (km)',
              hint: 'e.g., 50000',
              enabled: isEditing,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _colorController,
              label: 'Color',
              hint: 'e.g., Silver',
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Additional notes...',
              enabled: isEditing,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            if (isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (widget.vehicle != null) {
                          setState(() => isEditing = false);
                          _initializeControllers();
                        } else {
                          Get.back();
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveVehicle,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: !enabled,
            fillColor: !enabled ? AppTheme.lightGray : AppTheme.primaryWhite,
          ),
        ),
      ],
    );
  }
}
