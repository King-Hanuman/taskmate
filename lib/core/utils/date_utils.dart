import 'package:intl/intl.dart';

/// Date/time utility helpers for TaskMate.
class AppDateUtils {
  AppDateUtils._();

  /// Format: "Rabu, 10 Sep 2026"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
  }

  /// Format: "10 Sep 2026"
  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Format: "10 Sep"
  static String formatMinimalDate(DateTime date) {
    return DateFormat('d MMM', 'id_ID').format(date);
  }

  /// Format: "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format: "10 Sep 2026, 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Human-readable relative time: "2 hari lagi", "3 jam lagi", "Terlambat 1 hari"
  static String formatRelativeDeadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      // Already overdue
      final absDiff = diff.abs();
      if (absDiff.inDays > 0) {
        return 'Terlambat ${absDiff.inDays} hari';
      } else if (absDiff.inHours > 0) {
        return 'Terlambat ${absDiff.inHours} jam';
      } else {
        return 'Terlambat ${absDiff.inMinutes} menit';
      }
    } else {
      // Future deadline
      if (diff.inDays > 7) {
        return '${diff.inDays} hari lagi';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} hari lagi';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam lagi';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit lagi';
      } else {
        return 'Sebentar lagi';
      }
    }
  }

  /// Returns a greeting based on time of day.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is overdue (past and not today).
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) && !isToday(date);
  }
}
