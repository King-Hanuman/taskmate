import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmate/core/constants/app_constants.dart';
import 'package:taskmate/data/models/task_model.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';

/// Repository for Task CRUD operations via Firestore.
class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get reference to user's tasks subcollection.
  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════

  /// Create a new task. Returns the generated document ID.
  Future<String> createTask(Task task) async {
    final docRef = await _tasksRef(task.userId).add(
      TaskModel.toFirestore(task),
    );
    return docRef.id;
  }

  // ═══════════════════════════════════════════════════════════════════
  // READ (Real-time streams)
  // ═══════════════════════════════════════════════════════════════════

  /// Watch ALL tasks for this user in real time.
  /// Eliminates the need for Firestore composite indexes by streaming the subcollection directly.
  Stream<List<Task>> watchAllTasks(String userId) {
    return _tasksRef(userId).snapshots().map((snapshot) {
      final tasks = <Task>[];
      for (final doc in snapshot.docs) {
        try {
          if (doc.exists) {
            tasks.add(TaskModel.fromFirestore(doc));
          }
        } catch (_) {
          // Ignore corrupted doc rather than crashing the stream
        }
      }
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      return tasks;
    });
  }

  /// Watch tasks due TODAY.
  Stream<List<Task>> watchTodayTasks(String userId) {
    return watchAllTasks(userId).map((tasks) {
      return tasks.where((t) => t.isToday && !t.isArchived).toList();
    });
  }

  /// Watch OVERDUE tasks (deadline passed, not completed).
  Stream<List<Task>> watchOverdueTasks(String userId) {
    return watchAllTasks(userId).map((tasks) {
      return tasks.where((t) => t.isOverdue && !t.isArchived).toList();
    });
  }

  /// Watch UPCOMING tasks (future deadline, limited count).
  Stream<List<Task>> watchUpcomingTasks(String userId, {int limit = 5}) {
    return watchAllTasks(userId).map((tasks) {
      return tasks
          .where((t) => t.isUpcoming && !t.isArchived)
          .take(limit)
          .toList();
    });
  }

  /// Watch ARCHIVED tasks.
  Stream<List<Task>> watchArchivedTasks(String userId) {
    return _tasksRef(userId).snapshots().map((snapshot) {
      final tasks = <Task>[];
      for (final doc in snapshot.docs) {
        try {
          if (doc.exists) {
            final task = TaskModel.fromFirestore(doc);
            if (task.isArchived) {
              tasks.add(task);
            }
          }
        } catch (_) {
          // Ignore corrupted doc
        }
      }
      tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return tasks;
    });
  }

  /// Get a single task by ID.
  Future<Task?> getTaskById(String userId, String taskId) async {
    final doc = await _tasksRef(userId).doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════

  /// Update a task entirely (with merge to prevent crash if doc missing).
  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _tasksRef(task.userId).doc(task.id).set(
      TaskModel.toFirestore(updated),
      SetOptions(merge: true),
    );
  }

  /// Quick-update just the status field.
  Future<void> updateTaskStatus(
      String userId, String taskId, TaskStatus status) async {
    await _tasksRef(userId).doc(taskId).set({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════

  /// Permanently delete a task.
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }

  /// Archive a task (soft-delete).
  Future<void> archiveTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).update({
      'isArchived': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Restore a task from archive.
  Future<void> unarchiveTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).update({
      'isArchived': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Get task count stats for dashboard.
  Future<Map<String, int>> getTaskStats(String userId) async {
    final snapshot = await _tasksRef(userId)
        .where('isArchived', isEqualTo: false)
        .get();

    final tasks = snapshot.docs.map((d) => TaskModel.fromFirestore(d)).toList();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    int today = 0;
    int overdue = 0;
    int active = 0;
    int completed = 0;

    for (final task in tasks) {
      if (task.status == TaskStatus.selesai) {
        completed++;
        continue;
      }
      active++;
      if (task.deadline.isAfter(startOfDay) &&
          task.deadline.isBefore(endOfDay)) {
        today++;
      }
      if (task.deadline.isBefore(startOfDay)) {
        overdue++;
      }
    }

    return {
      'today': today,
      'overdue': overdue,
      'active': active,
      'completed': completed,
      'total': tasks.length,
    };
  }
}
