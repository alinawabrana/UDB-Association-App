import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/subscription/models/branch_model.dart';
import 'package:udb_association/src/features/branches/providers/branch_users_provider.dart';
import 'package:udb_association/src/features/branches/screens/user_detail_screen.dart';
// TODO: Uncomment when backend implementation is ready
// import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:udb_association/utils/constants/urls.dart';

class BranchDetailScreen extends ConsumerStatefulWidget {
  final Branch branch;

  const BranchDetailScreen({super.key, required this.branch});

  @override
  ConsumerState<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends ConsumerState<BranchDetailScreen> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final branchUsersAsync = ref.watch(
      branchUsersWithCountsProvider(widget.branch.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch.name),
        backgroundColor: const Color(0xFF6B7B4F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // TODO: Uncomment when backend implementation is ready
          // IconButton(
          //   icon: const Icon(Icons.chat, color: Colors.white),
          //   onPressed: () {
          //     // Navigate to chat screen with branch info
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ChatScreen(
          //           recipientId: widget.branch.id,
          //           recipientName: widget.branch.name,
          //           recipientProfession: 'Branch',
          //           recipientImage: widget.branch.image ?? '',
          //           chatType: 'branch',
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Branch Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6B7B4F), Color(0xFF5A6B3F)],
                ),
              ),
              child: Column(
                children: [
                  // Branch Logo/Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.branch.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              ApiUrls.getMediaUrl(widget.branch.image!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Color(0xFF6B7B4F),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            size: 40,
                            color: Color(0xFF6B7B4F),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Branch Name
                  Text(
                    widget.branch.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Branch Description
                  if (widget.branch.description != null &&
                      widget.branch.description!.isNotEmpty)
                    Text(
                      widget.branch.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  // Branch Address
                  if (widget.branch.address != null &&
                      widget.branch.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.branch.address!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Branch Contact Info
                  if (widget.branch.phone != null ||
                      widget.branch.email != null) ...[
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        if (widget.branch.phone != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.branch.phone!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (widget.branch.email != null)
                            const SizedBox(height: 4),
                        ],
                        if (widget.branch.email != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.branch.email!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Members and Managers Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  branchUsersAsync.when(
                    data: (branchUsers) {
                      return Column(
                        children: [
                          // Members Card
                          _TeamCard(
                            title: 'Members',
                            count: branchUsers.memberCount,
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(
                                    branchId: widget.branch.id,
                                    branchName: widget.branch.name,
                                    userType: 'members',
                                    users: branchUsers.members,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Managers Card
                          _TeamCard(
                            title: 'Managers',
                            count: branchUsers.managerCount,
                            icon: Icons.admin_panel_settings,
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(
                                    branchId: widget.branch.id,
                                    branchName: widget.branch.name,
                                    userType: 'managers',
                                    users: branchUsers.managers,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6B7B4F),
                        ),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading team data',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isRetrying
                                ? null
                                : () async {
                                    setState(() {
                                      _isRetrying = true;
                                    });

                                    try {
                                      ref.invalidate(
                                        branchUsersWithCountsProvider(
                                          widget.branch.id,
                                        ),
                                      );
                                      // Wait for the provider to complete
                                      await ref.read(
                                        branchUsersWithCountsProvider(
                                          widget.branch.id,
                                        ).future,
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isRetrying = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7B4F),
                              foregroundColor: Colors.white,
                            ),
                            child: _isRetrying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Retry'),
                          ),
                        ],
                      ),
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
}

class _TeamCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TeamCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count == 1 ? 'person' : 'people',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
