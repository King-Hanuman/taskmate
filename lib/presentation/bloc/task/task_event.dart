import 'package:equatable/equatable.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Task events for the TaskBloc.
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

/// Load all tasks (starts listening to stream).
class TaskLoadAll extends TaskEvent {
  final String userId;
  const TaskLoadAll(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Tasks received from Firestore stream.
class TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  const TasksUpdated(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

/// Create a new task.
class TaskCreate extends TaskEvent {
  final Task task;
  const TaskCreate(this.task);
  @override
  List<Object?> get props => [task];
}

/// Update an existing task.
class TaskUpdate extends TaskEvent {
  final Task task;
  const TaskUpdate(this.task);
  @override
  List<Object?> get props => [task];
}

/// Update only the status of a task.
class TaskUpdateStatus extends TaskEvent {
  final String userId;
  final String taskId;
  final TaskStatus status;
  const TaskUpdateStatus({
    required this.userId,
    required this.taskId,
    required this.status,
  });
  @override
  List<Object?> get props => [userId, taskId, status];
}

/// Delete a task permanently.
class TaskDelete extends TaskEvent {
  final String userId;
  final String taskId;
  const TaskDelete({required this.userId, required this.taskId});
  @override
  List<Object?> get props => [userId, taskId];
}

/// Archive a task.
class TaskArchive extends TaskEvent {
  final String userId;
  final String taskId;
  const TaskArchive({required this.userId, required this.taskId});
  @override
  List<Object?> get props => [userId, taskId];
}

/// Unarchive a task.
class TaskUnarchive extends TaskEvent {
  final String userId;
  final String taskId;
  const TaskUnarchive({required this.userId, required this.taskId});
  @override
  List<Object?> get props => [userId, taskId];
}

/// Apply a filter.
class TaskFilterChanged extends TaskEvent {
  final TaskCategory? category;
  final TaskPriority? priority;
  final TaskStatus? status;
  final String? searchQuery;
  const TaskFilterChanged({
    this.category,
    this.priority,
    this.status,
    this.searchQuery,
  });
  @override
  List<Object?> get props => [category, priority, status, searchQuery];
}

/// Apply sorting.
class TaskSortChanged extends TaskEvent {
  final String sortBy;
  final bool descending;
  const TaskSortChanged({required this.sortBy, this.descending = false});
  @override
  List<Object?> get props => [sortBy, descending];
}

/// Firestore stream error event.
class TaskStreamError extends TaskEvent {
  final String message;
  const TaskStreamError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Clear tasks and cancel stream on sign out.
class TaskClear extends TaskEvent {}

