import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskmate/core/constants/preset_avatars.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/presentation/bloc/profile/profile_cubit.dart';
import 'package:taskmate/presentation/bloc/profile/profile_state.dart';
import 'package:taskmate/presentation/widgets/user_avatar.dart';

/// Modal bottom sheet allowing users to choose preset avatars or upload custom photos.
class ProfilePhotoPickerSheet extends StatelessWidget {
  const ProfilePhotoPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfilePhotoPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor =
        isDark ? AppColors.darkCardAlt : const Color(0xFFE8E8F0);

    // Camera is available on mobile/tablet platforms
    final bool canUseCamera = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, profile) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── DRAG HANDLE ──
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── TITLE & CURRENT PREVIEW ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const UserAvatar(radius: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Foto Profil',
                            style: AppTypography.h3(
                              theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.photoBase64 != null
                                ? 'Foto Kustom Digunakan'
                                : (profile.photoUrl != null
                                    ? 'Avatar Pilihan Digunakan'
                                    : 'Inisial Nama Digunakan'),
                            style: AppTypography.caption(
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: borderColor, height: 1),

              // ── SCROLLABLE OPTIONS ──
              Flexible(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // SECTION 1: UPLOAD SENDIRI
                    Text(
                      'UPLOAD SENDIRI',
                      style: AppTypography.labelSmall(
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Gallery / File selector
                        Expanded(
                          child: _UploadCard(
                            icon: Icons.photo_library_rounded,
                            title: 'Galeri / File',
                            subtitle: 'Pilih dari perangkat',
                            cardColor: cardColor,
                            borderColor: borderColor,
                            isLoading: profile.isLoading,
                            onTap: () async {
                              final cubit = context.read<ProfileCubit>();
                              final success = await cubit.pickAndUploadImage(
                                source: ImageSource.gallery,
                              );
                              if (success &&
                                  context.mounted &&
                                  Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                        if (canUseCamera) ...[
                          const SizedBox(width: 12),
                          // Camera capture
                          Expanded(
                            child: _UploadCard(
                              icon: Icons.camera_alt_rounded,
                              title: 'Kamera',
                              subtitle: 'Ambil foto baru',
                              cardColor: cardColor,
                              borderColor: borderColor,
                              isLoading: profile.isLoading,
                              onTap: () async {
                                final cubit = context.read<ProfileCubit>();
                                final success = await cubit.pickAndUploadImage(
                                  source: ImageSource.camera,
                                );
                                if (success &&
                                    context.mounted &&
                                    Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION 2: AVATAR YANG DISEDIAKAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PILIH AVATAR RESMI',
                          style: AppTypography.labelSmall(
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          '12 Karakter',
                          style: AppTypography.caption(
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid of 12 preset avatars
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: PresetAvatars.list.length,
                      itemBuilder: (context, index) {
                        final preset = PresetAvatars.list[index];
                        final isSelected = profile.photoUrl == preset.url;

                        return InkWell(
                          onTap: profile.isLoading
                              ? null
                              : () {
                                  final cubit = context.read<ProfileCubit>();
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                  cubit.selectPresetAvatar(preset.url);
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : borderColor,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        preset.url,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(Icons.person_rounded),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                preset.name,
                                style: AppTypography.caption(
                                  isSelected
                                      ? AppColors.primary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                ).copyWith(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // SECTION 3: HAPUS FOTO JIKA ADA
                    if (profile.hasAvatar) ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: profile.isLoading
                            ? null
                            : () {
                                final cubit = context.read<ProfileCubit>();
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                                cubit.removeAvatar();
                              },
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        label: const Text('Hapus Foto Profil (Pakai Inisial)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color borderColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.borderColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge(
                      theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
