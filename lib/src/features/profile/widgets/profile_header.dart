import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:udb_association/src/common/widgets/circular_container.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_booking_provider.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/urls.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    super.key,
    this.showBackArrow = false,
    required this.user,
    this.onImageTap,
    this.selectedImage,
  });

  final bool showBackArrow;
  final User user;
  final VoidCallback? onImageTap;
  final File? selectedImage;

  String _getDisplayName(User user) {
    if (user.name.isNotEmpty) {
      return user.name;
    }
    // Construct from first_name and surname
    final firstName = user.firstName ?? '';
    final surname = user.surname ?? '';
    if (firstName.isNotEmpty && surname.isNotEmpty) {
      return '$firstName $surname';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (surname.isNotEmpty) {
      return surname;
    }
    // Fallback to email or user ID
    if (user.email.isNotEmpty) {
      return user.email.split('@').first;
    }
    return user.id != null ? 'User ${user.id}' : 'User';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      height: 312,
      padding: EdgeInsets.all(17),
      decoration: BoxDecoration(gradient: AColors.primaryLinearGradientDark),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showBackArrow
                  ? GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : SizedBox(),
              // SizedBox(),
              Text(
                l10n.translate('profile_header_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(),
            ],
          ),
          SizedBox(height: 40),
          // Show camera icon only in edit mode (when showBackArrow is true and onImageTap is provided)
          showBackArrow && onImageTap != null
              ? Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: _buildProfileImage(
                        user.profileImage,
                        selectedImage,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircularContainer(
                        icon: Icons.camera_alt,
                        onTap: onImageTap,
                      ),
                    ),
                  ],
                )
              : CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: _buildProfileImage(user.profileImage, selectedImage),
                ),
          SizedBox(height: 16),
          Text(
            _getDisplayName(user),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            user.id != null && user.id!.isNotEmpty
                ? l10n.translate(
                    'profile_header_member_id',
                    params: {'id': user.id!},
                  )
                : l10n.translate('profile_header_member_id_default'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8A9B5C),
            ),
          ),
          SizedBox(height: 6),
          // Conditional display based on user role
          _buildRoleBadges(context, ref, user.role ?? 'user'),
        ],
      ),
    );
  }

  Widget _buildRoleBadges(BuildContext context, WidgetRef ref, String role) {
    final l10n = context.l10n;
    // (1) If role is "user" → show both "Become a Member" and "Become a Seller" buttons
    if (role.toLowerCase() == 'user') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          // Become a Member button
          GestureDetector(
            onTap: () =>
                context.go('/profile/subscription_selection?type=member'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.translate('profile_header_become_member'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          // Become a Seller button
          GestureDetector(
            onTap: () =>
                context.go('/profile/subscription_selection?type=vendor'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.translate('profile_header_become_vendor'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // (2) If role is "vendor" or "manager" → don't show any badges
    if (role.toLowerCase() == 'vendor' || role.toLowerCase() == 'manager') {
      return SizedBox.shrink();
    }

    // (3) For all other roles (like "member") → show subscription-based Member badge
    return _buildSubscriptionBadge(context, ref);
  }

  Widget _buildSubscriptionBadge(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subscriptionAsync = ref.watch(currentUserSubscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        String badgeText = l10n.translate(
          'profile_badge_premium',
        ); // Default fallback

        if (subscription != null && subscription.subscription != null) {
          final planName = subscription.subscription!.type;
          badgeText = _getFormattedPlanName(context, planName);
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.translate('profile_badge_premium'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      error: (err, stack) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.translate('profile_badge_premium'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getFormattedPlanName(BuildContext context, String planName) {
    final l10n = context.l10n;
    switch (planName.toLowerCase()) {
      case 'basic':
        return l10n.translate('profile_badge_basic');
      case 'standard':
        return l10n.translate('profile_badge_standard');
      case 'premium':
        return l10n.translate('profile_badge_premium');
      default:
        return l10n.translate('profile_badge_premium'); // Default fallback
    }
  }

  Widget _buildProfileImage(String? path, File? selectedImage) {
    // Priority 1: Show selected image if user has picked a new one
    if (selectedImage != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: FileImage(selectedImage),
      );
    }

    // Priority 2: Show existing profile image from server
    if (path != null && path.isNotEmpty) {
      return Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.network(
            ApiUrls.getProfileImageUrl(path),
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to default avatar if network image fails
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 48, color: Colors.grey[600]),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Priority 3: Show default placeholder if no image exists
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 48, color: Colors.grey[600]),
    );
  }
}
