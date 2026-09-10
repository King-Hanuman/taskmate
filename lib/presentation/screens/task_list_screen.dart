import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/widgets/category_chip.dart';
import 'package:taskmate/core/widgets/empty_state.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/domain/enums/enums.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';
import 'package:taskmate/presentation/bloc/task/task_state.dart';
import 'package:taskmate/presentation/widgets/task_card.dart';

/// All tasks screen with search, filter, and sort capabilities.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<TaskBloc>().add(TaskFilterChanged(
          category: _selectedCategory,
          priority: _selectedPriority,
          searchQuery: _searchController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Semua Tugas',
                style: AppTypography.h2(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: 'Cari tugas...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // ── CATEGORY FILTER ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  // "All" chip
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = null);
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedCategory == null
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedCategory == null
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        'Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedCategory == null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedCategory == null
                              ? AppColors.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category chips
                  ...TaskCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          category: cat,
                          isSelected: _selectedCategory == cat,
                          onTap: () {
                            setState(() {
                              _selectedCategory =
                                  _selectedCategory == cat ? null : cat;
                            });
                            _applyFilters();
                          },
                        ),
                      )),
                ],
              ),
            ),

            // ── SORT & PRIORITY FILTER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  // Priority filter
                  ...TaskPriority.values.map((p) {
                    final isSelected = _selectedPriority == p;
                    Color chipColor;
                    switch (p) {
                      case TaskPriority.high:
                        chipColor = AppColors.error;
                        break;
                      case TaskPriority.medium:
                        chipColor = AppColors.warning;
                        break;
                      case TaskPriority.low:
                        chipColor = AppColors.secondary;
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriority = isSelected ? null : p;
                          });
                          _applyFilters();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? chipColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? chipColor
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? chipColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // Sort button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.sort_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onSelected: (value) {
                      context.read<TaskBloc>().add(TaskSortChanged(
                            sortBy: value,
                            descending: value == 'createdAt',
                          ));
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: 'deadline', child: Text('Urutkan: Deadline')),
                      PopupMenuItem(
                          value: 'priority',
                          child: Text('Urutkan: Prioritas')),
                      PopupMenuItem(
                          value: 'title', child: Text('Urutkan: Judul')),
                      PopupMenuItem(
                          value: 'createdAt',
                          child: Text('Urutkan: Terbaru')),
                    ],
                  ),
                ],
              ),
            ),

            // ── TASK LIST ──
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                buildWhen: (previous, current) =>
                    current is! TaskOperationSuccess &&
                    current is! TaskOperationFailure,
                builder: (context, state) {
                  if (state is TaskLoading || state is TaskInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TaskError) {
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
                              'Gagal memuat tugas',
                              style: AppTypography.h4(
                                  Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: AppTypography.caption(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                final user =
                                    context.read<AuthService>().currentUser;
                                if (user != null) {
                                  context
                                      .read<TaskBloc>()
                                      .add(TaskLoadAll(user.uid));
                                }
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TaskLoaded) {
                    if (state.filteredTasks.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'Tidak ada tugas',
                        subtitle: _searchController.text.isNotEmpty ||
                                _selectedCategory != null ||
                                _selectedPriority != null
                            ? 'Coba ubah filter atau kata kunci pencarian'
                            : 'Tambahkan tugas baru dengan tombol +',
                        actionLabel: 'Tambah Tugas',
                        onAction: () =>
                            Navigator.of(context).pushNamed('/task-form'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: state.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = state.filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/task-detail', arguments: task),
                          onStatusToggle: () {
                            final next =
                                task.status == TaskStatus.belumDikerjakan
                                    ? TaskStatus.sedangDikerjakan
                                    : task.status ==
                                            TaskStatus.sedangDikerjakan
                                        ? TaskStatus.selesai
                                        : TaskStatus.belumDikerjakan;
                            context.read<TaskBloc>().add(TaskUpdateStatus(
                                  userId: task.userId,
                                  taskId: task.id,
                                  status: next,
                                ));
                          },
                          onArchive: () => context.read<TaskBloc>().add(
                                TaskArchive(
                                    userId: task.userId, taskId: task.id),
                              ),
                          onDelete: () => context.read<TaskBloc>().add(
                                TaskDelete(
                                    userId: task.userId, taskId: task.id),
                              ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
