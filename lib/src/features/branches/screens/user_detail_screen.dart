import 'package:flutter/material.dart';
import 'package:udb_association/src/features/branches/models/branch_user_model.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailScreen extends StatelessWidget {
  final int branchId;
  final String branchName;
  final String userType;
  final List<BranchUser> users;

  const UserDetailScreen({
    super.key,
    required this.branchId,
    required this.branchName,
    required this.userType,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userType.capitalize()} - $branchName'),
        backgroundColor: const Color(0xFF6B7B4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    userType == 'members'
                        ? Icons.people
                        : Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${userType} found',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserCard(
                  user: user,
                  onTap: () => _showUserDetailsDialog(context, user),
                );
              },
            ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, BranchUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6B7B4F).withOpacity(0.1),
                ),
                child: _getUserImage(user) != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          _getUserImage(user)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF6B7B4F),
                              size: 25,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF6B7B4F),
                        size: 25,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(user),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    // Show function under name if available, otherwise show role
                    if (user.function != null && user.function!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.function!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (user.role != null && user.role!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.role!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              if (user.email != null) ...[
                _DetailRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: user.email!,
                ),
                const SizedBox(height: 12),
              ],

              // Phone
              if (user.profile?.phone != null) ...[
                _DetailRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value:
                      '${user.profile!.countryCode ?? ''}${user.profile!.phone!}',
                ),
                const SizedBox(height: 12),
              ] else if (user.memberProfile?.phone != null) ...[
                _DetailRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value:
                      '${user.memberProfile!.countryCode ?? ''}${user.memberProfile!.phone!}',
                ),
                const SizedBox(height: 12),
              ] else if (user.managerProfile?.phone != null) ...[
                _DetailRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value:
                      '${user.managerProfile!.countryCode ?? ''}${user.managerProfile!.phone!}',
                ),
                const SizedBox(height: 12),
              ],

              // Address
              if (user.profile?.address != null &&
                  user.profile!.address!.isNotEmpty) ...[
                _DetailRow(
                  icon: Icons.location_on,
                  label: 'Address',
                  value: user.profile!.address!,
                ),
                const SizedBox(height: 12),
              ] else if (user.managerProfile?.address != null &&
                  user.managerProfile!.address!.isNotEmpty) ...[
                _DetailRow(
                  icon: Icons.location_on,
                  label: 'Address',
                  value: user.managerProfile!.address!,
                ),
                const SizedBox(height: 12),
              ],

              // Joined Date
              if (user.createdAt != null) ...[
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Joined',
                  value: _formatDate(user.createdAt!),
                ),
                const SizedBox(height: 12),
              ],

              // Redactor Status
              if (user.profile?.isRedactor != null) ...[
                _DetailRow(
                  icon: Icons.edit,
                  label: 'Redactor',
                  value: user.profile!.isRedactor! ? 'Yes' : 'No',
                ),
              ] else if (user.memberProfile?.isRedactor != null) ...[
                _DetailRow(
                  icon: Icons.edit,
                  label: 'Redactor',
                  value: user.memberProfile!.isRedactor! ? 'Yes' : 'No',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      recipientId: user.id,
                      recipientName: _getDisplayName(user),
                      recipientProfession: user.position ?? 'Member',
                      recipientImage: _getUserImage(user) ?? '',
                      chatType: 'user',
                    ),
                  ),
                );
              },
              child: const Text(
                'Chat',
                style: TextStyle(
                  color: Color(0xFF6B7B4F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDisplayName(BranchUser user) {
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
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@').first;
    }
    return 'User ${user.id}';
  }

  String? _getUserImage(BranchUser user) {
    // For members, use member_profile.profile_image
    if (user.role?.toLowerCase() == 'member' && user.memberProfile != null) {
      if (user.memberProfile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.memberProfile!.profileImage!);
      }
      if (user.memberProfile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(user.memberProfile!.profileImageUrl!);
      }
    }

    // For managers, use manager_profile.profile_image
    if (user.role?.toLowerCase() == 'manager' && user.managerProfile != null) {
      if (user.managerProfile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.managerProfile!.profileImage!);
      }
      if (user.managerProfile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(
          user.managerProfile!.profileImageUrl!,
        );
      }
    }

    // Fallback to common profile
    if (user.profile != null) {
      if (user.profile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImage!);
      }
      if (user.profile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImageUrl!);
      }
    }

    // Final fallback to user.image
    return ApiUrls.getProfileImageUrl(user.image);
  }
}

class _UserCard extends StatelessWidget {
  final BranchUser user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  String _getDisplayName(BranchUser user) {
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
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@').first;
    }
    return 'User ${user.id}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6B7B4F).withOpacity(0.1),
                ),
                child: _getUserImage(user) != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          _getUserImage(user)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF6B7B4F),
                              size: 25,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF6B7B4F),
                        size: 25,
                      ),
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(user),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    // Show function if available, otherwise show position, otherwise show role
                    if (user.function != null && user.function!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.function!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ] else if (user.position != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.position!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ] else if (user.role != null && user.role!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.role!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Call Button
                  IconButton(
                    icon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
                    onPressed: () {
                      final phoneNumber = _getUserPhoneNumber(user);
                      if (phoneNumber != null && phoneNumber.isNotEmpty) {
                        _makePhoneCall(context, phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No phone number available'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                  // Chat Button
                  IconButton(
                    icon: const Icon(Icons.chat, color: Color(0xFF6B7B4F)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientId: user.id,
                            recipientName: _getDisplayName(user),
                            recipientProfession: user.position ?? 'Member',
                            recipientImage: _getUserImage(user) ?? '',
                            chatType: 'user',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getUserImage(BranchUser user) {
    // For members, use member_profile.profile_image
    if (user.role?.toLowerCase() == 'member' && user.memberProfile != null) {
      if (user.memberProfile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.memberProfile!.profileImage!);
      }
      if (user.memberProfile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(user.memberProfile!.profileImageUrl!);
      }
    }

    // For managers, use manager_profile.profile_image
    if (user.role?.toLowerCase() == 'manager' && user.managerProfile != null) {
      if (user.managerProfile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.managerProfile!.profileImage!);
      }
      if (user.managerProfile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(
          user.managerProfile!.profileImageUrl!,
        );
      }
    }

    // Fallback to common profile
    if (user.profile != null) {
      if (user.profile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImage!);
      }
      if (user.profile!.profileImageUrl != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImageUrl!);
      }
    }

    // Final fallback to user.image
    return ApiUrls.getProfileImageUrl(user.image);
  }

  String? _getUserPhoneNumber(BranchUser user) {
    // Try to get phone from member profile
    if (user.memberProfile != null) {
      final phone = user.memberProfile!.phone?.trim();
      final countryCode = user.memberProfile!.countryCode?.trim();
      if (phone != null && phone.isNotEmpty) {
        if (countryCode != null && countryCode.isNotEmpty) {
          // If phone already starts with +, don't add country code
          if (phone.startsWith('+')) {
            return phone;
          }
          return '$countryCode$phone';
        }
        return phone;
      }
    }

    // Try to get phone from manager profile
    if (user.managerProfile != null) {
      final phone = user.managerProfile!.phone?.trim();
      final countryCode = user.managerProfile!.countryCode?.trim();
      if (phone != null && phone.isNotEmpty) {
        if (countryCode != null && countryCode.isNotEmpty) {
          // If phone already starts with +, don't add country code
          if (phone.startsWith('+')) {
            return phone;
          }
          return '$countryCode$phone';
        }
        return phone;
      }
    }

    // Try to get phone from common profile
    if (user.profile != null) {
      final phone = user.profile!.phone?.trim();
      final countryCode = user.profile!.countryCode?.trim();
      if (phone != null && phone.isNotEmpty) {
        if (countryCode != null && countryCode.isNotEmpty) {
          // If phone already starts with +, don't add country code
          if (phone.startsWith('+')) {
            return phone;
          }
          return '$countryCode$phone';
        }
        return phone;
      }
    }

    // Fallback to user.phone
    if (user.phone != null && user.phone!.isNotEmpty) {
      return user.phone!.trim();
    }

    return null;
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      // Trim and clean the phone number - remove all whitespace, dashes, parentheses, etc.
      // Keep only digits and + sign
      String cleanedNumber = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
      
      // Remove any remaining whitespace characters
      cleanedNumber = cleanedNumber.replaceAll(RegExp(r'\s+'), '');
      
      // Ensure the number is not empty
      if (cleanedNumber.isEmpty) {
        throw 'Invalid phone number';
      }
      
      // Create the tel: URI - ensure no spaces
      final uriString = 'tel:$cleanedNumber';
      final uri = Uri.parse(uriString);
      
      // Try to launch the dialer
      bool launched = false;
      
      // First try with external application mode
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        } catch (e) {
          // If external application fails, try platform default
          try {
            await launchUrl(uri);
            launched = true;
          } catch (e2) {
            throw 'Could not launch dialer: $e2';
          }
        }
      } else {
        throw 'No app available to handle phone calls';
      }
      
      if (!launched) {
        throw 'Could not launch dialer for $cleanedNumber';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make phone call: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7B4F)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
