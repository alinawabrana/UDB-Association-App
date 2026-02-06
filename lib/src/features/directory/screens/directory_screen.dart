import 'package:flutter/material.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/surveys/services/branch_users_service.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/subscription/services/branch_service.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final allDirectoryUsersProvider = FutureProvider<List<User>>((ref) async {
  final branchService = BranchService();
  final token = ref.read(authTokenProvider);
  final branches = await branchService.fetchBranches(token: token);
  final service = BranchUsersService();
  final futures = branches
      .map((branch) => service.fetchBranchUsers(branch.id, token))
      .toList();

  if (futures.isEmpty) {
    return const [];
  }

  final results = await Future.wait(futures);
  final Map<String, User> uniqueUsers = {};
  for (final list in results) {
    for (final user in list) {
      if (user.id != null) {
        uniqueUsers[user.id!] = user;
      }
    }
  }
  return uniqueUsers.values.toList();
});

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  static const String _categoryAll = '__all__';
  static const String _categoryMembers = '__members__';
  static const String _categoryManagers = '__managers__';

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = _categoryAll;
  String _searchQuery = '';

  final List<String> _categories = [
    _categoryAll,
    _categoryMembers,
    _categoryManagers,
  ];

  // Convert API users to professional format, excluding current user
  List<Map<String, dynamic>> _convertUsersToProfessionals(
    List<User> users,
    User currentUser,
  ) {
    return users.where((user) => user.id != currentUser.id).map((user) {
      // Determine category based on user role
      String category = _categoryMembers; // Default to Members
      if (user.role?.toLowerCase() == 'manager') {
        category = _categoryManagers;
      }

      // Get phone number with country code
      String? phoneNumber;
      if (user.phone != null && user.phone!.isNotEmpty) {
        final phone = user.phone!.trim();
        if (user.countryCode != null && user.countryCode!.isNotEmpty) {
          final countryCode = user.countryCode!.trim();
          // If phone already starts with +, don't add country code
          if (phone.startsWith('+')) {
            phoneNumber = phone;
          } else {
            phoneNumber = '$countryCode$phone';
          }
        } else {
          phoneNumber = phone;
        }
      }

      // Get display name safely
      String displayName = user.name;
      if (displayName.isEmpty) {
        final firstName = user.firstName ?? '';
        final surname = user.surname ?? '';
        if (firstName.isNotEmpty && surname.isNotEmpty) {
          displayName = '$firstName $surname';
        } else if (firstName.isNotEmpty) {
          displayName = firstName;
        } else if (surname.isNotEmpty) {
          displayName = surname;
        } else if (user.email.isNotEmpty) {
          displayName = user.email.split('@').first;
        } else {
          displayName = user.id != null ? 'User ${user.id}' : 'User';
        }
      }
      
      // Get function or role for profession display
      String profession = user.function ?? user.role ?? '';
      if (profession.isEmpty) {
        profession = user.businessName ?? '';
      }
      
      return {
        'id': user.id,
        'name': displayName,
        'profession': profession,
        'category': category,
        'rating': 4.5, // Default rating since API doesn't provide this
        'reviews': 0, // Default reviews since API doesn't provide this
        'location': user.address,
        'profileImage': _getUserImage(user),
        'phone': phoneNumber,
        'email': user.email,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _filteredProfessionals(
    List<User> users,
    User currentUser,
  ) {
    final allProfessionals = _convertUsersToProfessionals(users, currentUser);
    List<Map<String, dynamic>> filtered = allProfessionals;

    // Filter by category
    if (_selectedCategory != _categoryAll) {
      filtered = filtered.where((professional) {
        return professional['category'] == _selectedCategory;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((professional) {
        final name = (professional['name'] as String? ?? '').toLowerCase();
        final profession = (professional['profession'] as String? ?? '')
            .toLowerCase();
        final location = (professional['location'] as String? ?? '')
            .toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            profession.contains(query) ||
            location.contains(query);
      }).toList();
    }

    return filtered;
  }

  String? _getUserImage(User user) {
    // For members, use member_profile.profile_image
    if (user.role?.toLowerCase() == 'member' && user.profile != null) {
      if (user.profile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImage!);
      }
    }

    // For managers, use manager_profile.profile_image
    if (user.role?.toLowerCase() == 'manager' && user.profile != null) {
      if (user.profile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImage!);
      }
    }

    // Fallback to common profile
    if (user.profile != null) {
      if (user.profile!.profileImage != null) {
        return ApiUrls.getProfileImageUrl(user.profile!.profileImage!);
      }
    }

    // Final fallback to placeholder
    return 'https://via.placeholder.com/48';
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subscriptionStatusAsync = ref.watch(
      userHasApprovedSubscriptionProvider,
    );
    final isSpecialUser = subscriptionStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7B3A),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: null,
          title: Text(
            l10n.translate('directory_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // Get current user's profile to access branch ID
          final profileAsync = ref.watch(profileProvider);

          return profileAsync.when(
            data: (profile) {
              final roleLower = profile.role?.toLowerCase();
              final shouldLoadAll =
                  roleLower == 'vendor' ||
                  (roleLower == 'user' && isSpecialUser);

              AsyncValue<List<User>> usersAsync;
              if (shouldLoadAll) {
                usersAsync = ref.watch(allDirectoryUsersProvider);
              } else {
                final branchId = profile.userBranchId;
                if (branchId == null) {
                  return Center(
                    child: Text(
                      l10n.translate('directory_no_branch'),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                usersAsync = ref.watch(
                  BranchUsersService.branchUsersProvider(branchId),
                );
              }

              return usersAsync.when(
                data: (users) {
                  final filteredProfessionals = _filteredProfessionals(
                    users,
                    profile,
                  );

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _CategoryChips(
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredProfessionals.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? l10n.translate(
                                                'directory_empty_query',
                                                params: {'query': _searchQuery},
                                              )
                                            : l10n.translate(
                                                'directory_empty_category',
                                              ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.translate(
                                          'directory_empty_suggestion',
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredProfessionals.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final professional =
                                        filteredProfessionals[index];
                                    return _ProfessionalCard(
                                      professional: professional,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('directory_failed_load_professionals'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('directory_failed_load_profile'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: l10n.translate('directory_search_hint'),
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFADAEBC),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final label = () {
            switch (category) {
              case _DirectoryScreenState._categoryMembers:
                return l10n.translate('directory_category_members');
              case _DirectoryScreenState._categoryManagers:
                return l10n.translate('directory_category_managers');
              default:
                return l10n.translate('directory_category_all');
            }
          }();

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfessionalCard extends ConsumerWidget {
  const _ProfessionalCard({required this.professional});

  final Map<String, dynamic> professional;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rating =
        (professional['rating'] as num?)?.toStringAsFixed(1) ?? '4.5';
    final reviewsCount = professional['reviews'] as int? ?? 0;
    final reviewsLabel = reviewsCount == 0
        ? l10n.translate(
            'directory_rating_reviews_zero',
            params: {'rating': rating},
          )
        : l10n.translate(
            'directory_rating_reviews',
            params: {'rating': rating, 'reviews': reviewsCount.toString()},
          );
    final profession =
        professional['profession'] as String? ??
        l10n.translate('directory_profession_fallback');
    final location =
        professional['location'] as String? ??
        l10n.translate('directory_location_placeholder');

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    professional['profileImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFF6B7B3A),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profession,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          reviewsLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      final phoneNumber = professional['phone'] as String?;
                      if (phoneNumber != null && phoneNumber.isNotEmpty) {
                        _makePhoneCall(context, phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No phone number available',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientId: int.tryParse(
                              professional['id'].toString(),
                            ),
                            recipientName: professional['name'],
                            recipientProfession: profession,
                            recipientImage: professional['profileImage'],
                            chatType: 'user',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B7B3A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.message,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
