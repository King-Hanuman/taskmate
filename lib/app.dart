import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/config/routes.dart';
import 'package:taskmate/core/theme/app_theme.dart';
import 'package:taskmate/data/repositories/task_repository.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/presentation/bloc/auth/auth_bloc.dart';
import 'package:taskmate/presentation/bloc/auth/auth_event.dart';
import 'package:taskmate/presentation/bloc/auth/auth_state.dart';
import 'package:taskmate/presentation/bloc/profile/profile_cubit.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';
import 'package:taskmate/presentation/bloc/theme/theme_cubit.dart';

/// Root application widget.
class TaskMateApp extends StatelessWidget {
  const TaskMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final taskRepository = TaskRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<TaskRepository>.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
          BlocProvider(
            create: (_) => ProfileCubit(
              authService: authService,
            )..initUser(authService.currentUser?.uid ?? ''),
          ),
          BlocProvider(
            create: (_) =>
                AuthBloc(authService: authService)..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => TaskBloc(taskRepository: taskRepository),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Start listening to tasks and profile when user is authenticated.
              context
                  .read<TaskBloc>()
                  .add(TaskLoadAll(state.user.uid));
              context
                  .read<ProfileCubit>()
                  .initUser(state.user.uid);
            } else if (state is AuthUnauthenticated) {
              // Cleanly clear memory and cancel listeners when user logs out.
              context.read<TaskBloc>().add(TaskClear());
              context.read<ProfileCubit>().clear();
            }
          },
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'TaskMate',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            },
          ),
        ),
      ),
    );
  }
}
