import 'package:equatable/equatable.dart';

/// State representing the current user's profile info (avatar, display name, etc.).
class ProfileState extends Equatable {
  final String? photoUrl;
  final String? photoBase64;
  final String displayName;
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.photoUrl,
    this.photoBase64,
    this.displayName = 'User',
    this.email = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasAvatar =>
      (photoBase64 != null && photoBase64!.isNotEmpty) ||
      (photoUrl != null && photoUrl!.isNotEmpty);

  ProfileState copyWith({
    String? photoUrl,
    bool clearPhotoUrl = false,
    String? photoBase64,
    bool clearPhotoBase64 = false,
    String? displayName,
    String? email,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      photoBase64: clearPhotoBase64 ? null : (photoBase64 ?? this.photoBase64),
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        photoUrl,
        photoBase64,
        displayName,
        email,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
