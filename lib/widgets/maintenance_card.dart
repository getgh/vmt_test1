import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MaintenanceCard extends StatelessWidget {
  final String serviceType;
  final DateTime serviceDate;
  final double mileage;
  final String? servicedBy;
  final double? cost;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MaintenanceCard({
    Key? key,
    required this.serviceType,
    required this.serviceDate,
    required this.mileage,
    this.servicedBy,
    this.cost,
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
            border: Border.all(color: AppTheme.primaryRed, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            serviceType,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          serviceDate.toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
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
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.speed, color: AppTheme.darkGray, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${mileage.toStringAsFixed(0)} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (cost != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.attach_money, color: AppTheme.primaryGreen, size: 16),
                          Text(
                            cost!.toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (servicedBy != null) ...[
                const SizedBox(height: 8),
                Text(
                  'By: $servicedBy',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
