import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/branches/models/location_model.dart';
import 'package:udb_association/src/features/branches/providers/location_provider.dart';
import 'package:udb_association/src/features/branches/providers/all_branch_members_provider.dart';
import 'package:udb_association/src/features/branches/utils/member_to_agent_converter.dart';
import 'package:udb_association/src/features/branches/screens/province_detail_screen.dart';
import 'package:udb_association/src/features/branches/screens/agent_detail_screen.dart';
import 'package:udb_association/src/features/branches/screens/branch_detail_screen.dart';
import 'package:udb_association/src/features/subscription/models/branch_model.dart';
import 'package:udb_association/src/features/subscription/providers/branch_provider.dart';
import 'package:udb_association/utils/constants/urls.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7F39),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.translate('organes_title')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provinces Section (from API)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provinces Title
                  Text(
                    l10n.translate('organes_divisions'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final locationsAsync = ref.watch(locationsProvider);
                      return locationsAsync.when(
                        data: (locations) {
                          if (locations.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _buildProvinceCards(locations);
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.translate('error_loading_provinces'),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.invalidate(locationsProvider);
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: Text(l10n.translate('retry')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B7C32),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Divider
            const Divider(height: 1, thickness: 1),
          // Branches Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branches',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final branchesAsync = ref.watch(branchesProvider);
                      return branchesAsync.when(
                        data: (branches) {
                          if (branches.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _buildBranchCards(branches);
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.translate('error_loading_branches'),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.invalidate(branchesProvider);
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: Text(l10n.translate('retry')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B7C32),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Divider
            const Divider(height: 1, thickness: 1),
            // Effectif Section (Branch Members List)
            Consumer(
              builder: (context, ref, child) {
                final membersAsync = ref.watch(allBranchMembersProvider);
                
                return membersAsync.when(
                  data: (members) {
                    // Log all members data for debugging
                    print('📋 COMPANIES SCREEN - ALL BRANCH MEMBERS:');
                    print('═══════════════════════════════════════════');
                    print('Total Members: ${members.length}');
                    for (var member in members) {
                      print('Member ${member.user.id}:');
                      print('  Name: ${member.user.name}');
                      print('  Role: ${member.user.role}');
                      print('  Branch: ${member.branchName}');
                      print('  Image: ${member.user.image}');
                      print('  Member Profile: ${member.user.memberProfile?.profileImageUrl}');
                      print('  Manager Profile: ${member.user.managerProfile?.profileImageUrl}');
                      print('  Profile: ${member.user.profile?.profileImageUrl}');
                    }
                    print('═══════════════════════════════════════════');
                    
                    // Filter members based on search
                    final filteredMembers = _searchQuery.isEmpty
                        ? members
                        : members.where((member) {
                            final query = _searchQuery.toLowerCase();
                            return member.user.name.toLowerCase().contains(query) ||
                                (member.user.role != null && member.user.role!.toLowerCase().contains(query)) ||
                                member.branchName.toLowerCase().contains(query);
                          }).toList();

                    return Column(
                      children: [
                        // Effectif Header and Search
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.translate('organes_effectif'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    '${members.length} ${l10n.translate('organes_agents')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Search Bar
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: l10n.translate('organes_search_hint'),
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _searchQuery = '';
                                                _searchController.clear();
                                              });
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Members List
                        filteredMembers.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No members available'
                                        : 'No members found',
                                    style: const TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: filteredMembers.map((member) {
                                    return _MemberCard(
                                      member: member,
                                      onTap: () {
                                        final agent = convertMemberToAgent(member);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AgentDetailScreen(agent: agent),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.translate('error_loading_members'),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(allBranchMembersProvider);
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(l10n.translate('retry')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7C32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Bottom padding to account for footer tabs
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceCards(List<Location> locations) {
    // Split provinces into two columns
    final leftColumn = <Location>[];
    final rightColumn = <Location>[];

    for (int i = 0; i < locations.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(locations[i]);
      } else {
        rightColumn.add(locations[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.map((location) {
              return Column(
                children: [
                  _ProvinceCard(
                    location: location,
                    onTap: () => _navigateToProvince(location, context),
                  ),
                  if (location != leftColumn.last) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: rightColumn.map((location) {
              return Column(
                children: [
                  _ProvinceCard(
                    location: location,
                    onTap: () => _navigateToProvince(location, context),
                  ),
                  if (location != rightColumn.last) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _navigateToProvince(Location location, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProvinceDetailScreen(location: location),
      ),
    );
  }

  Widget _buildBranchCards(List<Branch> branches) {
    // Split branches into two columns (same as provinces)
    final leftColumn = <Branch>[];
    final rightColumn = <Branch>[];

    for (int i = 0; i < branches.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(branches[i]);
      } else {
        rightColumn.add(branches[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.map((branch) {
              return Column(
                children: [
                  _BranchCard(
                    branch: branch,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BranchDetailScreen(branch: branch),
                        ),
                      );
                    },
                  ),
                  if (branch != leftColumn.last) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: rightColumn.map((branch) {
              return Column(
                children: [
                  _BranchCard(
                    branch: branch,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BranchDetailScreen(branch: branch),
                        ),
                      );
                    },
                  ),
                  if (branch != rightColumn.last) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


class _ProvinceCard extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const _ProvinceCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6B7F39), // App bar green color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                location.province,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final VoidCallback onTap;

  const _BranchCard({required this.branch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB), // Nice blue color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                branch.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final BranchMember member;
  final VoidCallback onTap;

  const _MemberCard({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    // Display function if available, otherwise role
    final displayText = (user.function != null && user.function!.isNotEmpty)
        ? user.function!
        : (user.role ?? 'member');
    final roleBranch = '$displayText - ${member.branchName}';
    
    // Get profile image from various profile types - prioritize profile_image over profile_image_url
    String profileImage = '';
    if (user.memberProfile?.profileImage != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.memberProfile!.profileImage);
    } else if (user.memberProfile?.profileImageUrl != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.memberProfile!.profileImageUrl);
    } else if (user.managerProfile?.profileImage != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.managerProfile!.profileImage);
    } else if (user.managerProfile?.profileImageUrl != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.managerProfile!.profileImageUrl);
    } else if (user.profile?.profileImage != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.profile!.profileImage);
    } else if (user.profile?.profileImageUrl != null) {
      profileImage = ApiUrls.getProfileImageUrl(user.profile!.profileImageUrl);
    } else {
      profileImage = ApiUrls.getProfileImageUrl(user.image);
    }
    
    // Log member data for debugging
    print('👤 MEMBER CARD DATA:');
    print('═══════════════════════════════════════════');
    print('Member ID: ${user.id}');
    print('User Name: ${user.name}');
    print('User Role: ${user.role}');
    print('Branch Name: ${member.branchName}');
    print('User Image: ${user.image}');
    print('Member Profile Image: ${user.memberProfile?.profileImage}');
    print('Member Profile Image URL: ${user.memberProfile?.profileImageUrl}');
    print('Manager Profile Image: ${user.managerProfile?.profileImage}');
    print('Manager Profile Image URL: ${user.managerProfile?.profileImageUrl}');
    print('Profile Image: ${user.profile?.profileImage}');
    print('Profile Image URL: ${user.profile?.profileImageUrl}');
    print('Final Profile Image: $profileImage');
    print('═══════════════════════════════════════════');
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
              child: profileImage.isEmpty
                  ? _buildInitialsAvatar(user.name.isNotEmpty ? user.name : 'User')
                  : null,
              onBackgroundImageError: profileImage.isNotEmpty
                  ? (exception, stackTrace) {
                      print('❌ Image load error for member ${user.id}: $exception');
                      print('   Image URL: $profileImage');
                    }
                  : null,
            ),
            const SizedBox(width: 12),
            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : 'User ${user.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleBranch,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    if (name.isEmpty) {
      return const Text(
        '?',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    String initials;

    if (parts.isEmpty) {
      initials = '?';
    } else if (parts.length >= 2) {
      // Take first letter of first two words
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // Only one word, take first letter (or first two letters if available)
      final word = parts[0];
      initials = word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word[0].toUpperCase();
    }

    return Text(
      initials,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
