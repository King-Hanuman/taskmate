import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/utils/date_utils.dart';
import 'package:taskmate/core/widgets/priority_badge.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Task card widget with swipe actions and visual deadline indicator.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusToggle;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusToggle,
    this.onArchive,
    this.onDelete,
  });

  Color get _deadlineColor {
    if (task.status == TaskStatus.selesai) return AppColors.success;
    if (task.isOverdue) return AppColors.error;
    if (task.isToday) return AppColors.warning;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            if (onArchive != null)
              SlidableAction(
                onPressed: (_) => onArchive!(),
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                icon: Icons.archive_rounded,
                label: 'Arsip',
                borderRadius: BorderRadius.circular(12),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: 'Hapus',
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkCardAlt : const Color(0xFFE8E8F0),
                width: 1,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Deadline color strip
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: _deadlineColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Status checkbox
                              GestureDetector(
                                onTap: onStatusToggle,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: task.status == TaskStatus.selesai
                                        ? AppColors.success
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: task.status == TaskStatus.selesai
                                          ? AppColors.success
                                          : (isDark
                                              ? AppColors.textTertiaryDark
                                              : AppColors.textTertiaryLight),
                                      width: 2,
                                    ),
                                  ),
                                  child: task.status == TaskStatus.selesai
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : task.status == TaskStatus.sedangDikerjakan
                                          ? Icon(
                                              Icons.more_horiz_rounded,
                                              size: 16,
                                              color: AppColors.warning,
                                            )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: AppTypography.labelLarge(
                                    Theme.of(context).colorScheme.onSurface,
                                  ).copyWith(
                                    decoration: task.status == TaskStatus.selesai
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.status == TaskStatus.selesai
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.4)
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PriorityBadge(
                                priority: task.priority,
                                compact: true,
                              ),
                            ],
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 36),
                              child: Text(
                                task.description!,
                                style: AppTypography.bodySmall(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Row(
                              children: [
                                // Category chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: task.category.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        task.category.icon,
                                        size: 12,
                                        color: task.category.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.category.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: task.category.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Deadline
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: _deadlineColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppDateUtils.formatRelativeDeadline(
                                      task.deadline),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _deadlineColor,
                                  ),
                                ),
                                const Spacer(),
                                // Status label
                                Text(
                                  task.status.label,
                                  style: AppTypography.caption(
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
