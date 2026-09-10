import 'package:equatable/equatable.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Core Task entity representing a to-do item.
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final List<String> customTags;
  final DateTime deadline;
  final TaskPriority priority;
  final TaskStatus status;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.customTags = const [],
    required this.deadline,
    required this.priority,
    this.status = TaskStatus.belumDikerjakan,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Returns true if the deadline has passed and the task is not completed.
  bool get isOverdue =>
      deadline.isBefore(DateTime.now()) && status != TaskStatus.selesai;

  /// Returns true if the deadline is today.
  bool get isToday {
    final now = DateTime.now();
    return deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
  }

  /// Returns true if the deadline is in the future (not today, not overdue).
  bool get isUpcoming =>
      deadline.isAfter(DateTime.now()) && !isToday;

  /// Remaining time until deadline.
  Duration get timeRemaining => deadline.difference(DateTime.now());

  /// Create a copy with updated fields.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    List<String>? customTags,
    DateTime? deadline,
    TaskPriority? priority,
    TaskStatus? status,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      customTags: customTags ?? this.customTags,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        customTags,
        deadline,
        priority,
        status,
        isArchived,
        createdAt,
        updatedAt,
        userId,
      ];
}
