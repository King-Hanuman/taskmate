import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/presentation/bloc/profile/profile_state.dart';

/// Cubit for managing user profile (photo, display name) and avatar operations.
class ProfileCubit extends Cubit<ProfileState> {
  final AuthService _authService;
  final ImagePicker _imagePicker;
  StreamSubscription? _profileSubscription;

  ProfileCubit({
    required AuthService authService,
    ImagePicker? imagePicker,
  })  : _authService = authService,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(ProfileState(
          displayName: authService.displayName,
          email: authService.currentUser?.email ?? '',
          photoUrl: authService.photoUrl,
        ));

  /// Initialize real-time listening to user's Firestore profile.
  void initUser(String userId) {
    _profileSubscription?.cancel();

    // Initial state from local auth service
    emit(state.copyWith(
      displayName: _authService.displayName,
      email: _authService.currentUser?.email ?? '',
      photoUrl: _authService.photoUrl,
    ));

    _profileSubscription = _authService.userProfileStream(userId).listen(
      (data) {
        if (data != null) {
          final photoUrl = data['photoUrl'] as String?;
          final photoBase64 = data['photoBase64'] as String?;
          final displayName =
              data['displayName'] as String? ?? _authService.displayName;
          final email =
              data['email'] as String? ?? (_authService.currentUser?.email ?? '');

          emit(state.copyWith(
            photoUrl: photoUrl,
            clearPhotoUrl: photoUrl == null || photoUrl.isEmpty,
            photoBase64: photoBase64,
            clearPhotoBase64: photoBase64 == null || photoBase64.isEmpty,
            displayName: displayName,
            email: email,
            isLoading: false,
          ));
        }
      },
      onError: (e) {
        // Silently keep current auth profile on stream error
      },
    );
  }

  /// Select one of the curated preset avatars.
  Future<void> selectPresetAvatar(String url) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _authService.updateProfilePhoto(
        photoUrl: url,
        photoBase64: null,
      );
      emit(state.copyWith(
        photoUrl: url,
        clearPhotoBase64: true,
        isLoading: false,
        successMessage: 'Foto profil berhasil diperbarui!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memperbarui avatar: $e',
      ));
    }
  }

  /// Pick an image from gallery or camera and upload as profile picture.
  Future<bool> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile == null) return false;

      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      await _authService.updateProfilePhoto(
        photoBase64: base64String,
        photoUrl: null,
      );

      emit(state.copyWith(
        photoBase64: base64String,
        clearPhotoUrl: true,
        isLoading: false,
        successMessage: 'Foto profil kustom berhasil disimpan!',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memilih foto: $e',
      ));
      return false;
    }
  }

  /// Remove custom avatar, resetting to letter avatar.
  Future<void> removeAvatar() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _authService.clearProfilePhoto();
      emit(state.copyWith(
        clearPhotoUrl: true,
        clearPhotoBase64: true,
        isLoading: false,
        successMessage: 'Foto profil berhasil dihapus.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menghapus avatar: $e',
      ));
    }
  }

  /// Clear profile and cancel subscription on sign out.
  void clear() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    emit(const ProfileState());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
