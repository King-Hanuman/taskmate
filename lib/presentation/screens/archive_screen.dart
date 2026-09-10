import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/utils/date_utils.dart';
import 'package:taskmate/core/widgets/confirmation_dialog.dart';
import 'package:taskmate/core/widgets/empty_state.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/data/repositories/task_repository.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';

/// Archive screen showing completed/archived tasks.
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser!.uid;
    final taskRepository = context.read<TaskRepository>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arsip',
                    style: AppTypography.h2(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tugas yang sudah diarsipkan',
                    style: AppTypography.bodySmall(
                      Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: taskRepository.watchArchivedTasks(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(
                              'Gagal memuat arsip',
                              style: AppTypography.h4(
                                  Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: AppTypography.caption(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final archivedTasks = snapshot.data ?? [];

                  if (archivedTasks.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.archive_rounded,
                      title: 'Arsip Kosong',
                      subtitle:
                          'Tugas yang sudah diarsipkan akan muncul di sini',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: archivedTasks.length,
                    itemBuilder: (context, index) {
                      final task = archivedTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  context.read<TaskBloc>().add(TaskUnarchive(
                                        userId: task.userId,
                                        taskId: task.id,
                                      ));
                                },
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                icon: Icons.unarchive_rounded,
                                label: 'Kembalikan',
                                borderRadius: BorderRadius.circular(12),
                              ),
                              SlidableAction(
                                onPressed: (_) async {
                                  final confirmed =
                                      await ConfirmationDialog.show(
                                    context,
                                    title: 'Hapus Permanen?',
                                    message:
                                        'Tugas "${task.title}" akan dihapus secara permanen.',
                                    confirmText: 'Hapus',
                                    icon: Icons.delete_forever_rounded,
                                  );
                                  if (confirmed && context.mounted) {
                                    context.read<TaskBloc>().add(TaskDelete(
                                          userId: task.userId,
                                          taskId: task.id,
                                        ));
                                  }
                                },
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_forever_rounded,
                                label: 'Hapus',
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: task.category.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    task.category.icon,
                                    size: 20,
                                    color: task.category.color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: AppTypography.labelMedium(
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ).copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${task.category.label} • ${AppDateUtils.formatShortDate(task.deadline)}',
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
                                Icon(
                                  Icons.swipe_left_rounded,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
