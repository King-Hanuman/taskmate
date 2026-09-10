import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Auth states for the AuthBloc.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial/loading state.
class AuthInitial extends AuthState {}

/// Authentication in progress.
class AuthLoading extends AuthState {}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.uid];
}

/// User is NOT authenticated.
class AuthUnauthenticated extends AuthState {}

/// Authentication error.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
