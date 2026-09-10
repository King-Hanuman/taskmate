import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/widgets/confirmation_dialog.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/presentation/bloc/auth/auth_bloc.dart';
import 'package:taskmate/presentation/bloc/auth/auth_event.dart';
import 'package:taskmate/presentation/bloc/profile/profile_cubit.dart';
import 'package:taskmate/presentation/bloc/profile/profile_state.dart';
import 'package:taskmate/presentation/bloc/theme/theme_cubit.dart';
import 'package:taskmate/presentation/widgets/profile_photo_picker_sheet.dart';
import 'package:taskmate/presentation/widgets/user_avatar.dart';

/// Settings screen with Theme Switcher (Light/Dark) and Account Logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── HEADER ──
            Text(
              'Pengaturan',
              style: AppTypography.h2(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kelola preferensi dan akun TaskMate',
              style: AppTypography.bodySmall(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            // ── USER PROFILE CARD ──
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profile) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkCardAlt
                          : const Color(0xFFE8E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            radius: 30,
                            showEditBadge: true,
                            onEditTap: () =>
                                ProfilePhotoPickerSheet.show(context),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.displayName,
                                  style: AppTypography.h4(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.email.isNotEmpty
                                      ? profile.email
                                      : (user?.email ?? 'Tidak ada email'),
                                  style: AppTypography.caption(
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: isDark
                            ? AppColors.darkCardAlt
                            : const Color(0xFFE8E8F0),
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => ProfilePhotoPickerSheet.show(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ubah Foto Profil (Upload / Pilih Avatar)',
                                style:
                                    AppTypography.labelSmall(AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── PREFERENCES SECTION ──
            Text(
              'TAMPILAN',
              style: AppTypography.labelSmall(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),

            // Theme Switcher Tile
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDarkMode = themeMode == ThemeMode.dark;
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkCardAlt
                          : const Color(0xFFE8E8F0),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? AppColors.primary : Colors.amber)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: isDarkMode ? AppColors.primary : Colors.amber[800],
                        size: 22,
                      ),
                    ),
                    title: Text(
                      isDarkMode ? 'Mode Gelap (Dark Mode)' : 'Mode Terang (Light Mode)',
                      style: AppTypography.labelLarge(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      isDarkMode
                          ? 'Tampilan gelap nyaman di mata'
                          : 'Tampilan terang cerah dan jelas',
                      style: AppTypography.caption(
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                      onChanged: (val) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── APP INFO SECTION ──
            Text(
              'TENTANG',
              style: AppTypography.labelSmall(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkCardAlt
                      : const Color(0xFFE8E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TaskMate',
                          style: AppTypography.labelLarge(
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Versi 1.0.0 — Smart To-Do for Students',
                          style: AppTypography.caption(
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── SIGN OUT BUTTON ──
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Keluar dari Akun?',
                  message:
                      'Anda perlu login kembali untuk mengakses tugas-tugas Anda.',
                  confirmText: 'Keluar',
                  cancelText: 'Batal',
                  confirmColor: AppColors.error,
                  icon: Icons.logout_rounded,
                );

                if (confirmed && context.mounted) {
                  context.read<AuthBloc>().add(AuthSignOut());
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Keluar dari Akun'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for navigation bar
          ],
        ),
      ),
    );
  }
}
