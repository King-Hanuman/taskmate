import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/utils/date_utils.dart';
import 'package:taskmate/core/widgets/confirmation_dialog.dart';
import 'package:taskmate/core/widgets/priority_badge.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';
import 'package:taskmate/presentation/bloc/task/task_state.dart';

/// Detailed view of a single task.
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _currentTask;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _safePop() {
    if (_isPopping) return;
    _isPopping = true;
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Color _getDeadlineColor(Task t) {
    if (t.status == TaskStatus.selesai) return AppColors.success;
    if (t.isOverdue) return AppColors.error;
    if (t.isToday) return AppColors.warning;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<TaskBloc, TaskState>(
      buildWhen: (previous, current) => current is! TaskOperationFailure,
      listener: (context, state) {
        if (_isPopping) return;
        if (ModalRoute.of(context)?.isCurrent != true) return;

        List<Task>? allTasks;
        if (state is TaskLoaded) {
          allTasks = state.allTasks;
        } else if (state is TaskOperationSuccess) {
          allTasks = state.previousState.allTasks;
        }

        if (allTasks != null) {
          final matches = allTasks.where((t) => t.id == widget.task.id);
          if (matches.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tugas ini telah dihapus.'),
                backgroundColor: AppColors.error,
              ),
            );
            _safePop();
          } else {
            setState(() {
              _currentTask = matches.first;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is TaskLoaded) {
          final matches =
              state.allTasks.where((t) => t.id == widget.task.id);
          if (matches.isNotEmpty) {
            _currentTask = matches.first;
          }
        } else if (state is TaskOperationSuccess) {
          final matches =
              state.previousState.allTasks.where((t) => t.id == widget.task.id);
          if (matches.isNotEmpty) {
            _currentTask = matches.first;
          }
        }
        final currentTask = _currentTask;
        final deadlineColor = _getDeadlineColor(currentTask);

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail Tugas',
                style:
                    AppTypography.h4(Theme.of(context).colorScheme.onSurface)),
            actions: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/task-form', arguments: currentTask);
                },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                onPressed: () async {
                  final confirmed = await ConfirmationDialog.show(
                    context,
                    title: 'Hapus Tugas?',
                    message:
                        'Tugas "${currentTask.title}" akan dihapus secara permanen. Tindakan ini tidak bisa dibatalkan.',
                    confirmText: 'Hapus',
                    icon: Icons.delete_forever_rounded,
                  );
                  if (confirmed && context.mounted) {
                    context.read<TaskBloc>().add(
                          TaskDelete(
                              userId: currentTask.userId,
                              taskId: currentTask.id),
                        );
                    _safePop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── STATUS & PRIORITY ──
              Row(
                children: [
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(currentTask.status)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(currentTask.status),
                          size: 16,
                          color: _statusColor(currentTask.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentTask.status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(currentTask.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PriorityBadge(priority: currentTask.priority),
                  const Spacer(),
                  // Quick status change
                  PopupMenuButton<TaskStatus>(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'Ubah Status',
                    onSelected: (status) {
                      context.read<TaskBloc>().add(TaskUpdateStatus(
                            userId: currentTask.userId,
                            taskId: currentTask.id,
                            status: status,
                          ));
                    },
                    itemBuilder: (context) => TaskStatus.values
                        .map((s) => PopupMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Icon(_statusIcon(s),
                                      size: 18, color: _statusColor(s)),
                                  const SizedBox(width: 8),
                                  Text(s.label),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── TITLE ──
              Text(
                currentTask.title,
                style: AppTypography.h2(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // ── CATEGORY ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: currentTask.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(currentTask.category.icon,
                        size: 18, color: currentTask.category.color),
                    const SizedBox(width: 8),
                    Text(
                      currentTask.category.label,
                      style: TextStyle(
                        color: currentTask.category.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // ── TAGS ──
              if (currentTask.customTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: currentTask.customTags
                      .map((tag) => Chip(
                            label:
                                Text(tag, style: const TextStyle(fontSize: 11)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // ── DEADLINE SECTION ──
              _DetailRow(
                icon: Icons.schedule_rounded,
                iconColor: deadlineColor,
                label: 'Tenggat Waktu',
                value: AppDateUtils.formatDateTime(currentTask.deadline),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: deadlineColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: deadlineColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentTask.isOverdue
                          ? Icons.warning_rounded
                          : Icons.timer_outlined,
                      color: deadlineColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppDateUtils.formatRelativeDeadline(
                          currentTask.deadline),
                      style: TextStyle(
                        color: deadlineColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── DESCRIPTION ──
              if (currentTask.description != null &&
                  currentTask.description!.isNotEmpty) ...[
                _DetailRow(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.primary,
                  label: 'Deskripsi',
                  value: '',
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkCard : const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentTask.description!,
                    style: AppTypography.bodyMedium(
                      Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── METADATA ──
              _DetailRow(
                icon: Icons.access_time_rounded,
                iconColor: AppColors.textSecondaryDark,
                label: 'Dibuat',
                value: AppDateUtils.formatDateTime(currentTask.createdAt),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.update_rounded,
                iconColor: AppColors.textSecondaryDark,
                label: 'Terakhir diubah',
                value: AppDateUtils.formatDateTime(currentTask.updatedAt),
              ),

              const SizedBox(height: 32),

              // ── ARCHIVE BUTTON ──
              OutlinedButton.icon(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        TaskArchive(
                            userId: currentTask.userId,
                            taskId: currentTask.id),
                      );
                  _safePop();
                },
                icon: const Icon(Icons.archive_rounded, size: 20),
                label: const Text('Arsipkan Tugas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: const BorderSide(color: AppColors.info),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.belumDikerjakan:
        return AppColors.textSecondaryDark;
      case TaskStatus.sedangDikerjakan:
        return AppColors.warning;
      case TaskStatus.selesai:
        return AppColors.success;
    }
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.belumDikerjakan:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.sedangDikerjakan:
        return Icons.pending_rounded;
      case TaskStatus.selesai:
        return Icons.check_circle_rounded;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelSmall(
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        if (value.isNotEmpty) ...[
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodySmall(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}
