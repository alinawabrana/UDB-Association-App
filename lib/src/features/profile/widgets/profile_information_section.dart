import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/widgets/heading_tile.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:udb_association/src/features/profile/widgets/profile_info_tile.dart';
import 'package:udb_association/src/router/app_router.dart';

class PersonalInformationSection extends StatelessWidget {
  const PersonalInformationSection({super.key, required this.user});

  final User user;

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

  String _getPhoneDisplay(User user, AppLocalizations l10n) {
    final phone = user.phone;
    final countryCode = user.countryCode;
    
    print('📞 === PHONE DISPLAY DEBUG ===');
    print('Phone: $phone');
    print('Country Code: $countryCode');
    print('User Profile: ${user.profile}');
    print('Profile Phone: ${user.profile?.phone}');
    print('Profile Country Code: ${user.profile?.countryCode}');
    print('=== END PHONE DEBUG ===\n');
    
    if (phone == null || phone.isEmpty) {
      return 'Not set';
    }
    
    if (countryCode != null && countryCode.isNotEmpty) {
      // If phone already starts with +, don't add country code again
      if (phone.startsWith('+')) {
        return phone;
      }
      return '$countryCode $phone';
    }
    
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = l10n.locale.toLanguageTag();
    final createdAt = user.profile?.createdAt;
    final memberSince = createdAt != null
        ? DateFormat.yMMM(localeTag).format(createdAt)
        : l10n.translate('profile_personal_member_since_unknown');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeadingTile(
              icon: Icons.person,
              headingTitle: l10n.translate('profile_personal_info_title'),
            ),
          ),

          // Divider (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 18,
              children: [
                PersonalInfoTile(
                  title: l10n.translate('profile_personal_full_name'),
                  value: _getDisplayName(user),
                ),
                PersonalInfoTile(
                  title: l10n.translate('profile_personal_email'),
                  value: user.email,
                ),
                PersonalInfoTile(
                  title: l10n.translate('profile_personal_phone'),
                  value: _getPhoneDisplay(user, l10n),
                ),
                PersonalInfoTile(
                  title: l10n.translate('profile_personal_member_since'),
                  value: memberSince,
                ),
              ],
            ),
          ),

          // Divider before Edit button (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Edit button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => context.goNamed(AppRouteNames.editProfile),
              child: Row(
                spacing: 8,
                children: [
                  const Icon(Iconsax.edit, color: Color(0xFF3B82F6), size: 14),
                  Text(
                    l10n.translate('profile_personal_edit'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
