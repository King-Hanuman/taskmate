import 'package:flutter/material.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/presentation/screens/auth/login_screen.dart';
import 'package:taskmate/presentation/screens/auth/register_screen.dart';
import 'package:taskmate/presentation/screens/home_shell.dart';
import 'package:taskmate/presentation/screens/splash_screen.dart';
import 'package:taskmate/presentation/screens/task_detail_screen.dart';
import 'package:taskmate/presentation/screens/task_form_screen.dart';

/// Named route definitions for the app.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String taskForm = '/task-form';
  static const String taskDetail = '/task-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case register:
        return _slideRoute(const RegisterScreen(), settings);

      case home:
        return _fadeRoute(const HomeShell(), settings);

      case taskForm:
        final task = settings.arguments as Task?;
        return _slideRoute(
          TaskFormScreen(existingTask: task),
          settings,
          direction: AxisDirection.up,
        );

      case taskDetail:
        final task = settings.arguments as Task;
        return _slideRoute(
          TaskDetailScreen(task: task),
          settings,
        );

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute _slideRoute(
    Widget page,
    RouteSettings settings, {
    AxisDirection direction = AxisDirection.left,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case AxisDirection.left:
            begin = const Offset(1, 0);
            break;
          case AxisDirection.up:
            begin = const Offset(0, 1);
            break;
          case AxisDirection.right:
            begin = const Offset(-1, 0);
            break;
          case AxisDirection.down:
            begin = const Offset(0, -1);
            break;
        }
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
