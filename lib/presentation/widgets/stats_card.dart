import 'package:flutter/material.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';

/// Gradient stat card for dashboard.
class StatsCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Gradient gradient;

  const StatsCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: AppTypography.numberSmall(Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption(
                Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Pre-built stat cards.
  static StatsCard today(int count) => StatsCard(
        label: 'Hari Ini',
        count: count,
        icon: Icons.today_rounded,
        gradient: AppColors.warningGradient,
      );

  static StatsCard overdue(int count) => StatsCard(
        label: 'Terlambat',
        count: count,
        icon: Icons.warning_rounded,
        gradient: AppColors.errorGradient,
      );

  static StatsCard active(int count) => StatsCard(
        label: 'Aktif',
        count: count,
        icon: Icons.task_alt_rounded,
        gradient: AppColors.primaryGradient,
      );
}
