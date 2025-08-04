import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/authentication/domain/entities/user.dart';
import '../../theme/app_theme.dart';
import 'app_header_constants.dart';

/// User avatar component for the app header
class AppHeaderAvatar extends StatelessWidget {
  const AppHeaderAvatar({super.key, required this.user, this.onProfileTap, this.heroContext});

  final User user;
  final VoidCallback? onProfileTap;
  final String? heroContext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onProfileTap?.call();
        },
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: _buildAvatarDecoration(context),
          child: _buildAvatarContent(context),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    // Create a unique hero tag using multiple identifiers to ensure uniqueness
    final contextId = heroContext ?? 'default';
    final heroTag = 'user_avatar_${user.id}_${contextId}_${context.hashCode}';

    return Hero(
      tag: heroTag,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 2),
        ),
        child: CircleAvatar(
          radius: AppHeaderConstants.avatarRadius,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: user.profileImageUrl?.isNotEmpty == true ? NetworkImage(user.profileImageUrl!) : null,
          child: user.profileImageUrl?.isEmpty != false ? _buildAvatarInitials(context) : null,
        ),
      ),
    );
  }

  Widget _buildAvatarInitials(BuildContext context) {
    return Text(
      _getInitials(user),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }

  BoxDecoration _buildAvatarDecoration(BuildContext context) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.colorScheme.primary.withValues(alpha: 0.15),
          context.colorScheme.secondary.withValues(alpha: 0.1),
          context.colorScheme.tertiary.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      boxShadow: SolarDecorations.createElevationShadow(SolarElevation.md),
    );
  }

  String _getInitials(User user) {
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return user.name[0].toUpperCase();
    }
    return user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U';
  }
}
