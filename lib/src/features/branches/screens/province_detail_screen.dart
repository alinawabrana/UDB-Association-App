import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/branches/models/division_model.dart';
import 'package:udb_association/src/features/branches/models/location_model.dart';
import 'package:udb_association/src/features/branches/providers/all_branch_members_provider.dart';
import 'package:udb_association/src/features/branches/utils/member_to_agent_converter.dart';
import 'package:udb_association/src/features/branches/screens/department_detail_screen.dart';
import 'package:udb_association/src/features/branches/screens/agent_detail_screen.dart';
import 'package:udb_association/src/features/branches/screens/branch_detail_screen.dart';
import 'package:udb_association/src/features/subscription/models/branch_model.dart';
import 'package:udb_association/src/features/subscription/providers/branch_provider.dart';

class ProvinceDetailScreen extends ConsumerStatefulWidget {
  final Location? location;
  final Division? division; // Keep for backward compatibility

  const ProvinceDetailScreen({
    super.key,
    this.location,
    this.division,
  });

  @override
  ConsumerState<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends ConsumerState<ProvinceDetailScreen> {
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
    final location = widget.location;
    final division = widget.division;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7F39),
        foregroundColor: Colors.white,
        title: Text(location?.province ?? division?.name ?? 'Province'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      location?.province ?? division?.name ?? 'Province',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Department Buttons (from Location API)
            if (location != null && location.departments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Departments',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: location.departments.map((deptName) {
                        return _DepartmentButton(
                          departmentName: deptName,
                          provinceName: location.province,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DepartmentDetailScreen(
                                  departmentName: deptName,
                                  provinceName: location.province,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
            ],
            // Branch Section (filtered by province)
            Consumer(
              builder: (context, ref, child) {
                final branchesAsync = ref.watch(branchesProvider);
                final provinceName = location?.province ?? division?.name;
                
                return branchesAsync.when(
                  data: (branches) {
                    // Filter branches by province
                    final provinceBranches = provinceName != null
                        ? branches.where((branch) => 
                            branch.province?.toLowerCase() == provinceName.toLowerCase()
                          ).toList()
                        : <Branch>[];
                    
                    if (provinceBranches.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    // Display branches in 2 columns
                    return Padding(
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
                          _buildBranchCards(context, provinceBranches),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            // Divider before agents if branches are shown
            Consumer(
              builder: (context, ref, child) {
                final branchesAsync = ref.watch(branchesProvider);
                final provinceName = location?.province ?? division?.name;
                
                return branchesAsync.when(
                  data: (branches) {
                    final provinceBranches = provinceName != null
                        ? branches.where((branch) => 
                            branch.province?.toLowerCase() == provinceName.toLowerCase()
                          ).toList()
                        : <Branch>[];
                    return provinceBranches.isNotEmpty 
                        ? const Divider(height: 1, thickness: 1) 
                        : const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            // Effectif Section (Branch Members)
            Consumer(
              builder: (context, ref, child) {
                final membersAsync = ref.watch(allBranchMembersProvider);
                final provinceName = location?.province ?? division?.name;
                
                return membersAsync.when(
                  data: (allMembers) {
                    // Filter members by province
                    final provinceMembers = provinceName != null
                        ? allMembers.where((member) => 
                            member.branchProvince?.toLowerCase() == provinceName.toLowerCase()
                          ).toList()
                        : <BranchMember>[];
                    
                    // Filter members based on search
                    final filteredMembers = _searchQuery.isEmpty
                        ? provinceMembers
                        : provinceMembers.where((member) {
                            final query = _searchQuery.toLowerCase();
                            return member.user.name.toLowerCase().contains(query) ||
                                (member.user.role != null && member.user.role!.toLowerCase().contains(query)) ||
                                member.branchName.toLowerCase().contains(query);
                          }).toList();

                    return Column(
                      children: [
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
                                    '${provinceMembers.length} ${l10n.translate('organes_agents')}',
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
                        if (filteredMembers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No members found',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = filteredMembers[index];
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
                            },
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
                      child: Text(
                        'Error loading members: ${error.toString()}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCards(BuildContext context, List<Branch> branches) {
    // Split branches into two columns
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

class _ContactIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ContactIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6B7F39),
          size: 20,
        ),
      ),
    );
  }
}

class _DepartmentButton extends StatelessWidget {
  final String departmentName;
  final String provinceName;
  final VoidCallback onTap;

  const _DepartmentButton({
    required this.departmentName,
    required this.provinceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6B7F39), // App bar green color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  'D',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                departmentName,
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
    final role = user.role ?? 'member';
    final roleBranch = '$role - ${member.branchName}';
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              child: user.image != null
                  ? ClipOval(
                      child: Image.network(
                        user.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsAvatar(user.name),
                      ),
                    )
                  : _buildInitialsAvatar(user.name),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
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
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      initials = parts[0][0].toUpperCase();
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

