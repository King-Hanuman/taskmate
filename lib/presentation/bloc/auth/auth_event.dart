import 'package:equatable/equatable.dart';

/// Auth events for the AuthBloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Check current auth state on app start.
class AuthCheckRequested extends AuthEvent {}

/// Sign in with email and password.
class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Register a new account with email.
class AuthRegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthRegisterWithEmail({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sign in with Google.
class AuthSignInWithGoogle extends AuthEvent {}

/// Sign out.
class AuthSignOut extends AuthEvent {}
