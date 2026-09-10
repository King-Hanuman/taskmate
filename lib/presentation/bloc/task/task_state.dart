import 'package:equatable/equatable.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Task states for the TaskBloc.
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

/// Initial/loading state.
class TaskInitial extends TaskState {}

/// Tasks loading.
class TaskLoading extends TaskState {}

/// Tasks loaded successfully.
class TaskLoaded extends TaskState {
  final List<Task> allTasks;
  final List<Task> filteredTasks;
  final TaskCategory? filterCategory;
  final TaskPriority? filterPriority;
  final TaskStatus? filterStatus;
  final String? searchQuery;
  final String sortBy;
  final bool sortDescending;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.filterCategory,
    this.filterPriority,
    this.filterStatus,
    this.searchQuery,
    this.sortBy = 'deadline',
    this.sortDescending = false,
  });

  /// Convenience getters for dashboard.
  List<Task> get todayTasks => allTasks.where((t) => t.isToday && !t.isArchived).toList();
  List<Task> get overdueTasks => allTasks.where((t) => t.isOverdue && !t.isArchived).toList();
  List<Task> get upcomingTasks => allTasks.where((t) => t.isUpcoming && !t.isArchived).toList();
  List<Task> get activeTasks => allTasks.where((t) => !t.isArchived && t.status != TaskStatus.selesai).toList();
  List<Task> get completedTasks => allTasks.where((t) => t.status == TaskStatus.selesai).toList();

  TaskLoaded copyWith({
    List<Task>? allTasks,
    List<Task>? filteredTasks,
    TaskCategory? filterCategory,
    TaskPriority? filterPriority,
    TaskStatus? filterStatus,
    String? searchQuery,
    String? sortBy,
    bool? sortDescending,
    bool clearCategoryFilter = false,
    bool clearPriorityFilter = false,
    bool clearStatusFilter = false,
    bool clearSearch = false,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      filterCategory: clearCategoryFilter ? null : (filterCategory ?? this.filterCategory),
      filterPriority: clearPriorityFilter ? null : (filterPriority ?? this.filterPriority),
      filterStatus: clearStatusFilter ? null : (filterStatus ?? this.filterStatus),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    filterCategory,
    filterPriority,
    filterStatus,
    searchQuery,
    sortBy,
    sortDescending,
  ];
}

/// Task operation error.
class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Task operation success (for snackbar notifications).
class TaskOperationSuccess extends TaskState {
  final String message;
  final TaskLoaded previousState;
  const TaskOperationSuccess({required this.message, required this.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

/// Task operation failure (for snackbar notifications, preserves loaded state).
class TaskOperationFailure extends TaskState {
  final String message;
  final TaskLoaded previousState;
  const TaskOperationFailure({required this.message, required this.previousState});
  @override
  List<Object?> get props => [message, previousState];
}
