import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/presentation/bloc/profile/profile_cubit.dart';
import 'package:taskmate/presentation/bloc/profile/profile_state.dart';

/// Reusable User Avatar widget that displays either custom base64 image,
/// network preset image, or letter avatar, with optional edit badge.
class UserAvatar extends StatelessWidget {
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.radius = 24,
    this.showEditBadge = false,
    this.onEditTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profile) {
        Widget avatarContent;

        if (profile.photoBase64 != null &&
            profile.photoBase64!.isNotEmpty) {
          try {
            final imageBytes = base64Decode(profile.photoBase64!);
            avatarContent = ClipOval(
              child: Image.memory(
                imageBytes,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(profile),
              ),
            );
          } catch (_) {
            avatarContent = _buildFallback(profile);
          }
        } else if (profile.photoUrl != null &&
            profile.photoUrl!.isNotEmpty) {
          avatarContent = ClipOval(
            child: Image.network(
              profile.photoUrl!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    width: radius * 0.8,
                    height: radius * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => _buildFallback(profile),
            ),
          );
        } else {
          avatarContent = _buildFallback(profile);
        }

        final mainAvatar = Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: avatarContent,
        );

        if (!showEditBadge) {
          if (onTap != null) {
            return InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: mainAvatar,
            );
          }
          return mainAvatar;
        }

        // With edit badge
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: onEditTap ?? onTap,
              customBorder: const CircleBorder(),
              child: mainAvatar,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onEditTap ?? onTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallback(ProfileState profile) {
    final initial = profile.displayName.isNotEmpty
        ? profile.displayName.substring(0, 1).toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
