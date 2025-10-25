import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderCard extends StatelessWidget {
  final String serviceType;
  final DateTime reminderDate;
  final bool isActive;
  final bool isOverdue;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;
  final VoidCallback? onDelete;

  const ReminderCard({
    Key? key,
    required this.serviceType,
    required this.reminderDate,
    required this.isActive,
    required this.isOverdue,
    required this.onTap,
    required this.onToggle,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppTheme.primaryRed : AppTheme.primaryGreen;
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            color: isOverdue ? AppTheme.primaryRed.withOpacity(0.05) : AppTheme.primaryWhite,
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
                        Row(
                          children: [
                            if (isOverdue)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'OVERDUE',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'UPCOMING',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          serviceType,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminderDate.toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: isActive,
                          onChanged: onToggle,
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.primaryRed),
                          iconSize: 20,
                          onPressed: onDelete,
                        ),
                    ],
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
