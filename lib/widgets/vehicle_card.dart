import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VehicleCard extends StatelessWidget {
  final String make;
  final String model;
  final int year;
  final double mileage;
  final String licensePlate;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VehicleCard({
    Key? key,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
    required this.licensePlate,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryGreen, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$year $make $model',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'License: $licensePlate',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.primaryRed),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.speed, color: AppTheme.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${mileage.toStringAsFixed(0)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
