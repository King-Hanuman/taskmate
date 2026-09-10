import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/utils/date_utils.dart';

import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/domain/enums/enums.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';
import 'package:taskmate/presentation/bloc/task/task_state.dart';
import 'package:taskmate/presentation/widgets/profile_photo_picker_sheet.dart';
import 'package:taskmate/presentation/widgets/stats_card.dart';
import 'package:taskmate/presentation/widgets/task_card.dart';
import 'package:taskmate/presentation/widgets/user_avatar.dart';

/// Dashboard — main home screen with overview and quick stats.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();


    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          buildWhen: (previous, current) =>
              current is! TaskOperationSuccess &&
              current is! TaskOperationFailure,
          builder: (context, state) {
            if (state is TaskInitial) {
              final user = authService.currentUser;
              if (user != null) {
                context.read<TaskBloc>().add(TaskLoadAll(user.uid));
              }
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TaskError) {
              final isPermissionDenied =
                  state.message.contains('permission-denied');
              final isNotFound = state.message.contains('not-found');

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Gagal Memuat Data',
                        style: AppTypography.h3(
                          Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPermissionDenied
                            ? 'Akses Firestore ditolak (Permission Denied). Pastikan Cloud Firestore sudah diaktifkan di Firebase Console dan atur Rules ke Test Mode.'
                            : isNotFound
                                ? 'Database Firestore belum dibuat. Buka Firebase Console > Build > Firestore Database > Create Database.'
                                : state.message,
                        style: AppTypography.bodySmall(
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          final user = authService.currentUser;
                          if (user != null) {
                            context.read<TaskBloc>().add(TaskLoadAll(user.uid));
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state is TaskLoaded ? state : null;
            final todayTasks = loaded?.todayTasks ?? [];
            final overdueTasks = loaded?.overdueTasks ?? [];
            final activeTasks = loaded?.activeTasks ?? [];
            final upcomingTasks = loaded?.upcomingTasks.take(5).toList() ?? [];

            return CustomScrollView(
              slivers: [
                // ── HEADER ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppDateUtils.getGreeting()} 👋',
                                style: AppTypography.bodyMedium(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authService.displayName,
                                style: AppTypography.h2(
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile avatar (tap to change avatar / upload)
                        UserAvatar(
                          radius: 22,
                          onTap: () => ProfilePhotoPickerSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── DATE ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Text(
                      AppDateUtils.formatFullDate(DateTime.now()),
                      style: AppTypography.caption(
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),

                // ── STATS CARDS ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        StatsCard.today(todayTasks.length),
                        const SizedBox(width: 10),
                        StatsCard.overdue(overdueTasks.length),
                        const SizedBox(width: 10),
                        StatsCard.active(activeTasks.length),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── OVERDUE TASKS ──
                if (overdueTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Terlambat',
                            style: AppTypography.h4(AppColors.error),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${overdueTasks.length}',
                              style: AppTypography.labelSmall(AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = overdueTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/task-detail', arguments: task),
                          onStatusToggle: () => _toggleStatus(context, task),
                          onArchive: () => context.read<TaskBloc>().add(
                                TaskArchive(
                                    userId: task.userId, taskId: task.id),
                              ),
                        );
                      },
                      childCount: overdueTasks.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],

                // ── TODAY'S TASKS ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hari Ini',
                          style: AppTypography.h4(
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${todayTasks.length}',
                            style: AppTypography.labelSmall(AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (todayTasks.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Tidak ada tugas hari ini 🎉',
                          style: AppTypography.bodyMedium(
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = todayTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/task-detail', arguments: task),
                          onStatusToggle: () => _toggleStatus(context, task),
                          onArchive: () => context.read<TaskBloc>().add(
                                TaskArchive(
                                    userId: task.userId, taskId: task.id),
                              ),
                        );
                      },
                      childCount: todayTasks.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── UPCOMING TASKS ──
                if (upcomingTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mendatang',
                            style: AppTypography.h4(
                              Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = upcomingTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/task-detail', arguments: task),
                          onStatusToggle: () => _toggleStatus(context, task),
                          onArchive: () => context.read<TaskBloc>().add(
                                TaskArchive(
                                    userId: task.userId, taskId: task.id),
                              ),
                        );
                      },
                      childCount: upcomingTasks.length,
                    ),
                  ),
                ],

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleStatus(BuildContext context, task) {
    final nextStatus = task.status == TaskStatus.belumDikerjakan
        ? TaskStatus.sedangDikerjakan
        : task.status == TaskStatus.sedangDikerjakan
            ? TaskStatus.selesai
            : TaskStatus.belumDikerjakan;

    context.read<TaskBloc>().add(TaskUpdateStatus(
          userId: task.userId,
          taskId: task.id,
          status: nextStatus,
        ));
  }
}
