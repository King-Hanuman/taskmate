/// App-wide constants for TaskMate.
class AppConstants {
  AppConstants._();

  static const String appName = 'TaskMate';
  static const String appTagline = 'Smart To-Do untuk Mahasiswa Sibuk';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // Default limits
  static const int dashboardUpcomingLimit = 5;
  static const int searchDebounceMs = 300;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(milliseconds: 2000);
}
