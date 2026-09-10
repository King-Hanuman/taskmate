import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/data/repositories/task_repository.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';
import 'task_event.dart';
import 'task_state.dart';

/// TaskBloc manages task list state with real-time Firestore sync.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TaskBloc({required this.taskRepository})
      : super(TaskInitial()) {
    on<TaskLoadAll>(_onLoadAll);
    on<TasksUpdated>(_onTasksUpdated);
    on<TaskStreamError>(_onStreamError);
    on<TaskCreate>(_onCreate);
    on<TaskUpdate>(_onUpdate);
    on<TaskUpdateStatus>(_onUpdateStatus);
    on<TaskDelete>(_onDelete);
    on<TaskArchive>(_onArchive);
    on<TaskUnarchive>(_onUnarchive);
    on<TaskFilterChanged>(_onFilterChanged);
    on<TaskSortChanged>(_onSortChanged);
    on<TaskClear>(_onClear);
  }

  Future<void> _onLoadAll(TaskLoadAll event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    await _tasksSubscription?.cancel();

    _tasksSubscription = taskRepository
        .watchAllTasks(event.userId)
        .listen(
      (tasks) {
        add(TasksUpdated(tasks));
      },
      onError: (error) {
        add(TaskStreamError(error.toString()));
      },
    );
  }

  void _onStreamError(TaskStreamError event, Emitter<TaskState> emit) {
    emit(TaskError(event.message));
  }

  Future<void> _onClear(TaskClear event, Emitter<TaskState> emit) async {
    await _tasksSubscription?.cancel();
    _tasksSubscription = null;
    emit(TaskInitial());
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final filtered = _applyFilters(
        event.tasks,
        category: currentState.filterCategory,
        priority: currentState.filterPriority,
        status: currentState.filterStatus,
        searchQuery: currentState.searchQuery,
        sortBy: currentState.sortBy,
        sortDescending: currentState.sortDescending,
      );
      emit(currentState.copyWith(
        allTasks: event.tasks,
        filteredTasks: filtered,
      ));
    } else {
      final filtered = _applyFilters(event.tasks);
      emit(TaskLoaded(
        allTasks: event.tasks,
        filteredTasks: filtered,
      ));
    }
  }

  Future<void> _onCreate(TaskCreate event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      final docId = await taskRepository.createTask(event.task);
      if (currentState is TaskLoaded) {
        final createdTask = event.task.copyWith(id: docId);
        if (!currentState.allTasks.any((t) => t.id == docId)) {
          final updatedAll = [createdTask, ...currentState.allTasks];
          final updatedFiltered = _applyFilters(
            updatedAll,
            category: currentState.filterCategory,
            priority: currentState.filterPriority,
            status: currentState.filterStatus,
            searchQuery: currentState.searchQuery,
            sortBy: currentState.sortBy,
            sortDescending: currentState.sortDescending,
          );
          emit(currentState.copyWith(
            allTasks: updatedAll,
            filteredTasks: updatedFiltered,
          ));
        }
      }
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: 'Gagal membuat tugas: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal membuat tugas: $e'));
      }
    }
  }

  Future<void> _onUpdate(TaskUpdate event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      TaskLoaded? nextState;
      if (currentState is TaskLoaded) {
        final updatedAll = currentState.allTasks.map((t) {
          return t.id == event.task.id ? event.task : t;
        }).toList();

        final updatedFiltered = _applyFilters(
          updatedAll,
          category: currentState.filterCategory,
          priority: currentState.filterPriority,
          status: currentState.filterStatus,
          searchQuery: currentState.searchQuery,
          sortBy: currentState.sortBy,
          sortDescending: currentState.sortDescending,
        );

        nextState = currentState.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        );

        // Immediately update local UI so edit is reflected without any lag
        emit(nextState);
      }

      await taskRepository.updateTask(event.task);

      if (nextState != null) {
        emit(TaskOperationSuccess(
          message: 'Tugas berhasil diperbarui',
          previousState: nextState,
        ));
        emit(nextState);
      }
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: e.toString().contains('not-found')
              ? 'Tugas ini sudah tidak ada (telah dihapus).'
              : 'Gagal mengupdate tugas: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal mengupdate tugas: $e'));
      }
    }
  }

  Future<void> _onUpdateStatus(
      TaskUpdateStatus event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      if (currentState is TaskLoaded) {
        final updatedAll = currentState.allTasks.map((t) {
          return t.id == event.taskId ? t.copyWith(status: event.status) : t;
        }).toList();

        final updatedFiltered = _applyFilters(
          updatedAll,
          category: currentState.filterCategory,
          priority: currentState.filterPriority,
          status: currentState.filterStatus,
          searchQuery: currentState.searchQuery,
          sortBy: currentState.sortBy,
          sortDescending: currentState.sortDescending,
        );

        emit(currentState.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        ));
      }

      await taskRepository.updateTaskStatus(
          event.userId, event.taskId, event.status);
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: 'Gagal mengupdate status: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal mengupdate status: $e'));
      }
    }
  }

  Future<void> _onDelete(TaskDelete event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      await taskRepository.deleteTask(event.userId, event.taskId);
      if (currentState is TaskLoaded) {
        final updatedAll =
            currentState.allTasks.where((t) => t.id != event.taskId).toList();
        final updatedFiltered = _applyFilters(
          updatedAll,
          category: currentState.filterCategory,
          priority: currentState.filterPriority,
          status: currentState.filterStatus,
          searchQuery: currentState.searchQuery,
          sortBy: currentState.sortBy,
          sortDescending: currentState.sortDescending,
        );
        final nextState = currentState.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        );
        emit(TaskOperationSuccess(
          message: 'Tugas berhasil dihapus',
          previousState: nextState,
        ));
        emit(nextState);
      }
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: 'Gagal menghapus tugas: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal menghapus tugas: $e'));
      }
    }
  }

  Future<void> _onArchive(TaskArchive event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      await taskRepository.archiveTask(event.userId, event.taskId);
      if (currentState is TaskLoaded) {
        final updatedAll =
            currentState.allTasks.where((t) => t.id != event.taskId).toList();
        final updatedFiltered = _applyFilters(
          updatedAll,
          category: currentState.filterCategory,
          priority: currentState.filterPriority,
          status: currentState.filterStatus,
          searchQuery: currentState.searchQuery,
          sortBy: currentState.sortBy,
          sortDescending: currentState.sortDescending,
        );
        final nextState = currentState.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        );
        emit(TaskOperationSuccess(
          message: 'Tugas diarsipkan',
          previousState: nextState,
        ));
        emit(nextState);
      }
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: 'Gagal mengarsipkan tugas: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal mengarsipkan tugas: $e'));
      }
    }
  }

  Future<void> _onUnarchive(
      TaskUnarchive event, Emitter<TaskState> emit) async {
    final currentState = state;
    try {
      TaskLoaded? nextState;
      if (currentState is TaskLoaded) {
        final updatedAll = currentState.allTasks.map((t) {
          return t.id == event.taskId ? t.copyWith(isArchived: false) : t;
        }).toList();
        final updatedFiltered = _applyFilters(
          updatedAll,
          category: currentState.filterCategory,
          priority: currentState.filterPriority,
          status: currentState.filterStatus,
          searchQuery: currentState.searchQuery,
          sortBy: currentState.sortBy,
          sortDescending: currentState.sortDescending,
        );
        nextState = currentState.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        );
        emit(nextState);
      }

      await taskRepository.unarchiveTask(event.userId, event.taskId);

      if (nextState != null) {
        emit(TaskOperationSuccess(
          message: 'Tugas dikembalikan dari arsip',
          previousState: nextState,
        ));
        emit(nextState);
      }
    } catch (e) {
      if (currentState is TaskLoaded) {
        emit(TaskOperationFailure(
          message: 'Gagal mengembalikan tugas: $e',
          previousState: currentState,
        ));
        emit(currentState);
      } else {
        emit(TaskError('Gagal mengembalikan tugas: $e'));
      }
    }
  }

  void _onFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final filtered = _applyFilters(
        currentState.allTasks,
        category: event.category,
        priority: event.priority,
        status: event.status,
        searchQuery: event.searchQuery,
        sortBy: currentState.sortBy,
        sortDescending: currentState.sortDescending,
      );
      emit(currentState.copyWith(
        filteredTasks: filtered,
        filterCategory: event.category,
        filterPriority: event.priority,
        filterStatus: event.status,
        searchQuery: event.searchQuery,
        clearCategoryFilter: event.category == null,
        clearPriorityFilter: event.priority == null,
        clearStatusFilter: event.status == null,
        clearSearch: event.searchQuery == null || event.searchQuery!.isEmpty,
      ));
    }
  }

  void _onSortChanged(TaskSortChanged event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final filtered = _applyFilters(
        currentState.allTasks,
        category: currentState.filterCategory,
        priority: currentState.filterPriority,
        status: currentState.filterStatus,
        searchQuery: currentState.searchQuery,
        sortBy: event.sortBy,
        sortDescending: event.descending,
      );
      emit(currentState.copyWith(
        filteredTasks: filtered,
        sortBy: event.sortBy,
        sortDescending: event.descending,
      ));
    }
  }

  /// Apply filter + sort to task list.
  List<Task> _applyFilters(
    List<Task> tasks, {
    TaskCategory? category,
    TaskPriority? priority,
    TaskStatus? status,
    String? searchQuery,
    String sortBy = 'deadline',
    bool sortDescending = false,
  }) {
    var result = tasks.where((t) => !t.isArchived).toList();

    // Filter by category
    if (category != null) {
      result = result.where((t) => t.category == category).toList();
    }

    // Filter by priority
    if (priority != null) {
      result = result.where((t) => t.priority == priority).toList();
    }

    // Filter by status
    if (status != null) {
      result = result.where((t) => t.status == status).toList();
    }

    // Search by title or description
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'deadline':
          comparison = a.deadline.compareTo(b.deadline);
          break;
        case 'priority':
          comparison = a.priority.sortOrder.compareTo(b.priority.sortOrder);
          break;
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
        default:
          comparison = a.deadline.compareTo(b.deadline);
      }
      return sortDescending ? -comparison : comparison;
    });

    return result;
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
