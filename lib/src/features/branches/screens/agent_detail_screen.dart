import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/branches/models/division_model.dart';
import 'package:udb_association/src/features/branches/providers/all_branch_members_provider.dart';
import 'package:udb_association/src/features/branches/utils/member_to_agent_converter.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentDetailScreen extends ConsumerStatefulWidget {
  final Agent agent;

  const AgentDetailScreen({super.key, required this.agent});

  @override
  ConsumerState<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends ConsumerState<AgentDetailScreen> {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Log agent data for debugging
                  Builder(
                    builder: (context) {
                      print('👤 AGENT DETAIL SCREEN - AGENT DATA:');
                      print('═══════════════════════════════════════════');
                      print('Agent ID: ${widget.agent.id}');
                      print('Agent Name: ${widget.agent.name}');
                      print('Agent Role: ${widget.agent.role}');
                      print('Agent Title: ${widget.agent.title}');
                      print('Agent Profile Image: ${widget.agent.profileImage}');
                      print('Agent Email: ${widget.agent.email}');
                      print('Agent Phone: ${widget.agent.phone}');
                      print('Agent Function: ${widget.agent.function}');
                      print('Agent Direction: ${widget.agent.direction}');
                      print('Agent Branch: ${widget.agent.branchName}');
                      print('═══════════════════════════════════════════');
                      return const SizedBox.shrink();
                    },
                  ),
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE5E7EB),
                      image: widget.agent.profileImage != null && widget.agent.profileImage!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.agent.profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.agent.profileImage == null || widget.agent.profileImage!.isEmpty
                        ? _buildInitialsAvatar(widget.agent.name)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Name and Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.agent.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (widget.agent.title != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.agent.title!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // Geographic Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (widget.agent.province != null)
                    _DetailRow(
                      label: l10n.translate('organes_province'),
                      value: widget.agent.province!,
                    ),
                  if (widget.agent.departement != null) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.translate('organes_departement'),
                      value: widget.agent.departement!,
                    ),
                  ],
                  if (widget.agent.commune != null) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.translate('organes_commune'),
                      value: widget.agent.commune!,
                    ),
                  ],
                  if (widget.agent.arrondissement != null) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.translate('organes_arrondissement'),
                      value: widget.agent.arrondissement!,
                    ),
                  ],
                  if (widget.agent.division != null) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: 'Division',
                      value: widget.agent.division!,
                    ),
                  ],
                  if (widget.agent.function != null && widget.agent.function!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.translate('function_optional'),
                      value: widget.agent.function!,
                    ),
                  ],
                  if (widget.agent.direction != null && widget.agent.direction!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.translate('direction_optional'),
                      value: widget.agent.direction!,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // Contact Information
            if (widget.agent.phone != null || widget.agent.email != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.agent.phone != null)
                      Text(
                        widget.agent.phone!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    if (widget.agent.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.agent.email!,
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
                          onTap: () {
                            if (widget.agent.phone != null && widget.agent.phone!.isNotEmpty) {
                              _makePhoneCall(context, widget.agent.phone!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Phone number not available for this agent'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _ContactIcon(
                          icon: Icons.chat_bubble_outline,
                          onTap: () {
                            final recipientId = int.tryParse(widget.agent.id);
                            if (recipientId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    recipientId: recipientId,
                                    recipientName: widget.agent.name,
                                    recipientProfession: widget.agent.role ?? widget.agent.title,
                                    recipientImage: widget.agent.profileImage,
                                    chatType: 'user',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to start chat: Invalid user ID'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (widget.agent.phone != null || widget.agent.email != null)
              const Divider(height: 1, thickness: 1),
            // Agents List (Branch Members)
            Consumer(
              builder: (context, ref, child) {
                final membersAsync = ref.watch(allBranchMembersProvider);
                final branchName = widget.agent.branchName;
                
                return membersAsync.when(
                  data: (allMembers) {
                    // Log all members data for debugging
                    print('📋 AGENT DETAIL SCREEN - ALL BRANCH MEMBERS:');
                    print('═══════════════════════════════════════════');
                    print('Total Members: ${allMembers.length}');
                    print('Current Agent Branch: $branchName');
                    for (var member in allMembers) {
                      print('Member ${member.user.id}:');
                      print('  Name: ${member.user.name}');
                      print('  Role: ${member.user.role}');
                      print('  Branch: ${member.branchName}');
                      print('  Image: ${member.user.image}');
                      print('  Member Profile Image: ${member.user.memberProfile?.profileImage}');
                      print('  Member Profile Image URL: ${member.user.memberProfile?.profileImageUrl}');
                      print('  Manager Profile Image: ${member.user.managerProfile?.profileImage}');
                      print('  Manager Profile Image URL: ${member.user.managerProfile?.profileImageUrl}');
                      print('  Profile Image: ${member.user.profile?.profileImage}');
                      print('  Profile Image URL: ${member.user.profile?.profileImageUrl}');
                    }
                    print('═══════════════════════════════════════════');
                    
                    // Filter members by the same branch
                    final branchMembers = branchName != null
                        ? allMembers.where((member) => 
                            member.branchName.toLowerCase() == branchName.toLowerCase() &&
                            member.user.id.toString() != widget.agent.id
                          ).toList()
                        : <BranchMember>[];
                    
                    print('🔍 Filtered Branch Members: ${branchMembers.length}');
                    
                    // Filter members based on search
                    final filteredMembers = _searchQuery.isEmpty
                        ? branchMembers
                        : branchMembers.where((member) {
                            final query = _searchQuery.toLowerCase();
                            return member.user.name.toLowerCase().contains(query) ||
                                (member.user.role != null && member.user.role!.toLowerCase().contains(query)) ||
                                member.branchName.toLowerCase().contains(query);
                          }).toList();

                    return Column(
                      children: [
                        // Effectif Section Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
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
                              if (branchName != null)
                                Text(
                                  '${branchMembers.length} ${l10n.translate('organes_agents')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Search Bar (only show if there are branch members)
                        if (branchMembers.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
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
                          ),
                          const SizedBox(height: 8),
                        ],
                        // Members List
                        if (filteredMembers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                branchName != null
                                    ? (_searchQuery.isEmpty
                                        ? 'No other members in this branch'
                                        : 'No members found')
                                    : 'No branch information available',
                                style: const TextStyle(color: Color(0xFF6B7280)),
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
                              final agent = convertMemberToAgent(member);
                              return _AgentCard(
                                agent: agent,
                                onTap: () {
                                  Navigator.pushReplacement(
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

  Widget _buildInitialsAvatar(String name) {
    if (name.isEmpty) {
      return const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    String initials;
    
    if (parts.isEmpty) {
      initials = '?';
    } else if (parts.length >= 2) {
      // Take first letter of first two words
      initials = '${parts[0][0]}${parts[1][0]}';
    } else {
      // Only one word, take first letter
      initials = parts[0][0];
    }

    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
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

class _AgentCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback onTap;

  const _AgentCard({
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: agent.profileImage != null && agent.profileImage!.isNotEmpty
                  ? NetworkImage(agent.profileImage!)
                  : null,
              child: agent.profileImage == null || agent.profileImage!.isEmpty
                  ? _buildInitialsAvatar(agent.name.isNotEmpty ? agent.name : 'User')
                  : null,
              onBackgroundImageError: agent.profileImage != null && agent.profileImage!.isNotEmpty
                  ? (exception, stackTrace) {
                      print('❌ Agent card image load error for ${agent.id}: $exception');
                      print('   Image URL: ${agent.profileImage}');
                    }
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (agent.title != null || agent.role != null)
                    Text(
                      '${agent.title ?? ''}${agent.title != null && agent.role != null ? ' · ' : ''}${agent.role ?? ''}',
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
      initials = '${parts[0][0]}${parts[1][0]}';
    } else {
      // Only one word, take first letter
      initials = parts[0][0];
    }

    return Text(
      initials.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

