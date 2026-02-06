import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/branches/models/division_model.dart';
import 'package:udb_association/src/features/branches/models/static_data.dart';
import 'package:udb_association/src/features/branches/providers/all_branch_members_provider.dart';
import 'package:udb_association/src/features/branches/utils/member_to_agent_converter.dart';
import 'package:udb_association/src/features/branches/screens/agent_detail_screen.dart';
import 'package:udb_association/src/features/branches/screens/branch_detail_screen.dart';
import 'package:udb_association/src/features/subscription/models/branch_model.dart';
import 'package:udb_association/src/features/subscription/providers/branch_provider.dart';

class DepartmentDetailScreen extends ConsumerStatefulWidget {
  final Department? department; // Keep for backward compatibility
  final String? departmentName; // New: from Location API
  final String? provinceName; // New: from Location API

  const DepartmentDetailScreen({
    super.key,
    this.department,
    this.departmentName,
    this.provinceName,
  });

  @override
  ConsumerState<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends ConsumerState<DepartmentDetailScreen> {
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
    final department = widget.department;
    final departmentName = widget.departmentName ?? department?.name ?? 'Department';
    final provinceName = widget.provinceName;
    final division = department != null
        ? StaticOrganesData.getDivisionById(department.divisionId)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7F39),
        foregroundColor: Colors.white,
        title: Text(provinceName != null
            ? '$provinceName / $departmentName'
            : (division != null
                ? '${division.name} / $departmentName'
                : departmentName)),
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
                        'D',
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
                      provinceName != null
                          ? '$provinceName / $departmentName'
                          : (division != null
                              ? '${division.name} / $departmentName'
                              : departmentName),
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
            // Description
            if ((department != null && department.description != null) ||
                (division != null && division.description != null))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  department?.description ??
                      division?.description ??
                      '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ),
            const Divider(height: 1, thickness: 1),
            // Contact Information
            if ((department != null && (department.phone != null || department.email != null)) ||
                (division != null &&
                    (division.phone != null || division.email != null)))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((department?.phone ?? division?.phone) != null)
                      Text(
                        department?.phone ?? division?.phone ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    if ((department?.email ?? division?.email) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        department?.email ?? division?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Contact Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ContactIcon(
                          icon: Icons.phone,
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _ContactIcon(
                          icon: Icons.chat_bubble_outline,
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _ContactIcon(
                          icon: Icons.email_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Divider(height: 1, thickness: 1),
            // Branch Section (filtered by department)
            Consumer(
              builder: (context, ref, child) {
                final branchesAsync = ref.watch(branchesProvider);
                
                return branchesAsync.when(
                  data: (branches) {
                    // Filter branches by department
                    final deptName = widget.departmentName ?? widget.department?.name;
                    final departmentBranches = deptName != null
                        ? branches.where((branch) => 
                            branch.department?.toLowerCase() == deptName.toLowerCase()
                          ).toList()
                        : <Branch>[];
                    
                    if (departmentBranches.isEmpty) {
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
                          _buildBranchCards(context, departmentBranches),
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
                
                return branchesAsync.when(
                  data: (branches) {
                    final deptName = widget.departmentName ?? widget.department?.name;
                    final departmentBranches = deptName != null
                        ? branches.where((branch) => 
                            branch.department?.toLowerCase() == deptName.toLowerCase()
                          ).toList()
                        : <Branch>[];
                    return departmentBranches.isNotEmpty 
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
                final departmentName = widget.departmentName ?? widget.department?.name;
                
                return membersAsync.when(
                  data: (allMembers) {
                    // Filter members by department
                    final departmentMembers = departmentName != null
                        ? allMembers.where((member) => 
                            member.branchDepartment?.toLowerCase() == departmentName.toLowerCase()
                          ).toList()
                        : <BranchMember>[];
                    
                    // Filter members based on search
                    final filteredMembers = _searchQuery.isEmpty
                        ? departmentMembers
                        : departmentMembers.where((member) {
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
                                    '${departmentMembers.length} ${l10n.translate('organes_agents')}',
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

