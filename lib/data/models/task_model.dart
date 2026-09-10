import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Data model for Task with Firestore serialization.
class TaskModel {
  /// Convert Task entity to Firestore document map.
  static Map<String, dynamic> toFirestore(Task task) {
    return {
      'title': task.title,
      'description': task.description,
      'category': task.category.name,
      'customTags': task.customTags,
      'deadline': Timestamp.fromDate(task.deadline),
      'priority': task.priority.name,
      'status': task.status.name,
      'isArchived': task.isArchived,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': Timestamp.fromDate(task.updatedAt),
      'userId': task.userId,
    };
  }

  /// Create Task entity from Firestore document snapshot.
  static Task fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final now = DateTime.now();
    return Task(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Tanpa Judul',
      description: data['description'] as String?,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TaskCategory.lainnya,
      ),
      customTags: List<String>.from(data['customTags'] ?? []),
      deadline: data['deadline'] is Timestamp
          ? (data['deadline'] as Timestamp).toDate()
          : now.add(const Duration(days: 1)),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.belumDikerjakan,
      ),
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : now,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : now,
      userId: (data['userId'] as String?) ?? '',
    );
  }

  /// Create Task entity from a plain map (for local usage).
  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.lainnya,
      ),
      customTags: List<String>.from(map['customTags'] ?? []),
      deadline: map['deadline'] is Timestamp
          ? (map['deadline'] as Timestamp).toDate()
          : DateTime.parse(map['deadline'] as String),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.belumDikerjakan,
      ),
      isArchived: map['isArchived'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
      userId: map['userId'] as String,
    );
  }
}
