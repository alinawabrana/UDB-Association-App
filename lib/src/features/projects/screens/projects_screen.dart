import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import '../providers/projects_provider.dart';
import '../models/project_model.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectModel> _filterProjects(
    List<ProjectModel> projects,
    int? currentUserId,
    String? userRole,
    int? userBranchId,
  ) {
    // Apply branch filter for members and managers only (for branch-specific tabs)
    List<ProjectModel> branchFiltered = projects;
    final roleLower = (userRole ?? '').toLowerCase();
    if ((roleLower == 'member' || roleLower == 'manager') && userBranchId != null) {
      branchFiltered = projects.where((project) {
        return project.branchId == userBranchId;
      }).toList();
    }

    // Apply category filters
    List<ProjectModel> categoryFiltered;
    switch (_selectedCategoryIndex) {
      case 0: // All Projects - Show all projects regardless of branch
        categoryFiltered = projects;
        break;
      case 1: // My Branch - Show only branch-specific projects (members and managers only)
        if ((roleLower == 'member' || roleLower == 'manager') && userBranchId != null) {
          categoryFiltered = branchFiltered;
        } else {
          // For users and vendors, show empty (branch projects not applicable)
          categoryFiltered = [];
        }
        break;
      case 2: // Manager: Completed | Member: My Projects
        if (userRole?.toLowerCase() == 'manager') {
          // Manager: Show completed projects (100% tasks done) from all branches
          categoryFiltered = projects.where((project) {
            if (project.tasks.isEmpty) return false;
            final completedTasks = project.tasks
                .where((task) => task.status == 'done')
                .length;
            return completedTasks == project.tasks.length;
          }).toList();
        } else {
          // Member: Show projects assigned to current user from all branches
          if (currentUserId == null) return [];
          categoryFiltered = projects.where((project) {
            return project.tasks.any(
              (task) => task.assignedTo == currentUserId,
            );
          }).toList();
        }
        break;
      case 3: // Manager: Incomplete | Member: Recent
        if (userRole?.toLowerCase() == 'manager') {
          // Manager: Show incomplete projects (not 100% done) from all branches
          categoryFiltered = projects.where((project) {
            if (project.tasks.isEmpty) return true; // No tasks = incomplete
            final completedTasks = project.tasks
                .where((task) => task.status == 'done')
                .length;
            return completedTasks < project.tasks.length;
          }).toList();
        } else {
          // Member: Show recent projects (within 3 days) from all branches
          final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
          categoryFiltered = projects.where((project) {
            try {
              final createdAt = DateTime.parse(project.createdAt);
              return createdAt.isAfter(threeDaysAgo);
            } catch (e) {
              return false;
            }
          }).toList();
        }
        break;
      default:
        categoryFiltered = projects;
    }

    // Apply text search across title and task titles
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      categoryFiltered = categoryFiltered.where((project) {
        final titleMatch = project.title.toLowerCase().contains(query);
        final taskMatch = project.tasks.any(
          (t) => t.title.toLowerCase().contains(query),
        );
        return titleMatch || taskMatch;
      }).toList();
    }

    return categoryFiltered;
  }

  List<ProjectModel> _sortProjectsByDate(List<ProjectModel> projects) {
    final sortedProjects = List<ProjectModel>.from(projects);
    sortedProjects.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.createdAt);
        final dateB = DateTime.parse(b.createdAt);
        // Sort in descending order (most recent first)
        return dateB.compareTo(dateA);
      } catch (e) {
        // If date parsing fails, keep original order
        return 0;
      }
    });
    return sortedProjects;
  }

  List<Map<String, dynamic>> _getCategoryChips(String? userRole, AppLocalizations l10n) {
    final roleLower = (userRole ?? '').toLowerCase();
    final chips = <Map<String, dynamic>>[];

    // All Projects - always shown
    chips.add({
      'label': l10n.translate('filter_all_projects'),
      'index': 0,
    });

    // My Branch tab - Always at index 1, only for members and managers
    if (roleLower == 'member' || roleLower == 'manager') {
      chips.add({
        'label': l10n.translate('my_branch'),
        'index': 1,
      });
    }

    if (roleLower == 'manager') {
      // Manager categories: Completed and Incomplete
      chips.add({
        'label': l10n.translate('filter_completed'),
        'index': 2,
      });
      chips.add({
        'label': l10n.translate('filter_incomplete'),
        'index': 3,
      });
    } else {
      // Member categories: My Projects and Recent
      chips.add({
        'label': l10n.translate('filter_my_projects'),
        'index': 2,
      });
      chips.add({
        'label': l10n.translate('filter_recent'),
        'index': 3,
      });
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userProfileAsync = ref.watch(profileProvider);
    final projectsAsync = ref.watch(projectsProvider);

    // Get user role and ID to determine UI behavior
    final userRole = userProfileAsync.when(
      data: (user) => user.role,
      loading: () => null,
      error: (_, __) => null,
    );

    final currentUserId = userProfileAsync.when(
      data: (user) => user.id != null ? int.tryParse(user.id!) : null,
      loading: () => null,
      error: (_, __) => null,
    );

    final userBranchId = userProfileAsync.when(
      data: (user) => user.userBranchId,
      loading: () => null,
      error: (_, __) => null,
    );

    final roleLower = (userRole ?? '').toLowerCase();
    final disableProjectDetails = roleLower == 'vendor' || roleLower == 'user';

    return Scaffold(
      drawer: null,
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7C32),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: null,
          title: Text(
            l10n.translate('projects'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          actions: [
            if (roleLower == 'member')
              Consumer(
                builder: (context, ref, _) {
                  final unreadAsync = ref.watch(
                    unreadNotificationsCountProvider,
                  );
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.goNamed(AppRouteNames.memberNotifications);
                        },
                        icon: const Icon(
                          Icons.notifications,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      unreadAsync.when(
                        data: (count) => count > 0
                            ? Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            userProfileAsync.when(
              data: (user) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      ApiUrls.getProfileImageUrl(user.profileImage),
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      print(
                        '⚠️ [PROJECTS SCREEN] Profile image failed to load: $exception',
                      );
                    },
                    child:
                        user.profileImage == null || user.profileImage!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 20,
                            color: Color(0xFF6B7C32),
                          )
                        : null,
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 20, color: Color(0xFF6B7C32)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // First Container - Search, Status Cards, and Category Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                // Search Bar
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: l10n.translate('search_projects_hint'),
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
                ),
                const SizedBox(height: 13),
                // Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 16),
                // Status Cards Row - Only show for managers
                if (userRole?.toLowerCase() == 'manager') ...[
                  projectsAsync.when(
                    data: (projectsResponse) {
                      final allProjects = projectsResponse.data;
                      final filteredProjects = _filterProjects(
                        allProjects,
                        currentUserId,
                        userRole,
                        userBranchId,
                      );
                      final sortedProjects = _sortProjectsByDate(
                        filteredProjects,
                      );

                      int todoCount = 0;
                      int inProgressCount = 0;
                      int toVerifyCount = 0;
                      int doneCount = 0;

                      for (final project in sortedProjects) {
                        for (final task in project.tasks) {
                          switch (task.status) {
                            case 'todo':
                              todoCount++;
                              break;
                            case 'in_progress':
                              inProgressCount++;
                              break;
                            case 'to_verify':
                              toVerifyCount++;
                              break;
                            case 'done':
                              doneCount++;
                              break;
                          }
                        }
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusCard(
                            icon: Icons.checklist,
                            label: l10n.translate('status_todo'),
                            count: todoCount.toString(),
                            iconColor: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFFDBEAFE),
                          ),
                          _StatusCard(
                            icon: Icons.access_time,
                            label: l10n.translate('status_in_progress'),
                            count: inProgressCount.toString(),
                            iconColor: const Color(0xFFCA8A04),
                            backgroundColor: const Color(0xFFFEF9C3),
                          ),
                          _StatusCard(
                            icon: Icons.remove_red_eye,
                            label: l10n.translate('status_to_verify'),
                            count: toVerifyCount.toString(),
                            iconColor: const Color(0xFFEA580C),
                            backgroundColor: const Color(0xFFFFEDD5),
                          ),
                          _StatusCard(
                            icon: Icons.check_circle,
                            label: l10n.translate('status_done'),
                            count: doneCount.toString(),
                            iconColor: const Color(0xFF16A34A),
                            backgroundColor: const Color(0xFFDCFCE7),
                          ),
                        ],
                      );
                    },
                    loading: () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusCard(
                          icon: Icons.checklist,
                          label: l10n.translate('status_todo'),
                          count: '0',
                          iconColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFDBEAFE),
                        ),
                        _StatusCard(
                          icon: Icons.access_time,
                          label: l10n.translate('status_in_progress'),
                          count: '0',
                          iconColor: const Color(0xFFCA8A04),
                          backgroundColor: const Color(0xFFFEF9C3),
                        ),
                        _StatusCard(
                          icon: Icons.remove_red_eye,
                          label: l10n.translate('status_to_verify'),
                          count: '0',
                          iconColor: const Color(0xFFEA580C),
                          backgroundColor: const Color(0xFFFFEDD5),
                        ),
                        _StatusCard(
                          icon: Icons.check_circle,
                          label: l10n.translate('status_done'),
                          count: '0',
                          iconColor: const Color(0xFF16A34A),
                          backgroundColor: const Color(0xFFDCFCE7),
                        ),
                      ],
                    ),
                    error: (_, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusCard(
                          icon: Icons.checklist,
                          label: l10n.translate('status_todo'),
                          count: '0',
                          iconColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFDBEAFE),
                        ),
                        _StatusCard(
                          icon: Icons.access_time,
                          label: l10n.translate('status_in_progress'),
                          count: '0',
                          iconColor: const Color(0xFFCA8A04),
                          backgroundColor: const Color(0xFFFEF9C3),
                        ),
                        _StatusCard(
                          icon: Icons.remove_red_eye,
                          label: l10n.translate('status_to_verify'),
                          count: '0',
                          iconColor: const Color(0xFFEA580C),
                          backgroundColor: const Color(0xFFFFEDD5),
                        ),
                        _StatusCard(
                          icon: Icons.check_circle,
                          label: l10n.translate('status_done'),
                          count: '0',
                          iconColor: const Color(0xFF16A34A),
                          backgroundColor: const Color(0xFFDCFCE7),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                // Category Chips - Different for managers vs members (Horizontal Scrollable)
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: _getCategoryChips(userRole, l10n).length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chip = _getCategoryChips(userRole, l10n)[index];
                      return _CategoryChip(
                        label: chip['label'] as String,
                        isSelected: chip['index'] as int == _selectedCategoryIndex,
                        onTap: () => setState(() => _selectedCategoryIndex = chip['index'] as int),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Second Container - Project Cards
          Expanded(
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: projectsAsync.when(
                data: (projectsResponse) {
                  final allProjects = projectsResponse.data;
                  final filteredProjects = _filterProjects(
                    allProjects,
                    currentUserId,
                    userRole,
                    userBranchId,
                  );

                  // Sort projects by creation date (most recent first)
                  final sortedProjects = _sortProjectsByDate(filteredProjects);

                  if (sortedProjects.isEmpty) {
                    String emptyMessage = l10n.translate(
                      'empty_projects_default',
                    );
                    switch (_selectedCategoryIndex) {
                      case 1:
                        emptyMessage = l10n.translate(
                          'empty_projects_branch',
                        );
                        break;
                      case 2:
                        if (userRole?.toLowerCase() == 'manager') {
                          emptyMessage = l10n.translate(
                            'empty_projects_completed',
                          );
                        } else {
                          emptyMessage = l10n.translate(
                            'empty_projects_assigned',
                          );
                        }
                        break;
                      case 3:
                        if (userRole?.toLowerCase() == 'manager') {
                          emptyMessage = l10n.translate(
                            'empty_projects_incomplete',
                          );
                        } else {
                          emptyMessage = l10n.translate(
                            'empty_projects_recent',
                          );
                        }
                        break;
                    }

                    return Center(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: sortedProjects.length,
                    itemBuilder: (context, index) {
                      final project = sortedProjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ProjectCard(
                          project: project,
                          onTap: disableProjectDetails
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProjectDetailScreen(project: project),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B7C32)),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('failed_to_load_projects'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(projectsProvider);
                        },
                        child: Text(l10n.translate('retry')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color iconColor;
  final Color backgroundColor;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 81,
      height: 92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7C32) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const _ProjectCard({required this.project, this.onTap});

  String _formatMonthYear(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    
    // Calculate progress percentage
    final totalTasks = project.tasks.length;
    final completedTasks = project.tasks
        .where((task) => task.status == 'done')
        .length;
    final completionPercentage = totalTasks > 0
        ? (completedTasks / totalTasks * 100).round()
        : 0;

    // Get first image URL
    String? firstImageUrl;
    if (project.images != null && project.images!.isNotEmpty) {
      firstImageUrl = ApiUrls.getMediaUrl(project.images!.first);
    }

    // Get tagline or use description
    final tagline = project.tagline ?? project.description;

    // Get end date (expire_date) formatted as "Month Year"
    DateTime? endDate;
    String dateText = '';
    if (project.expireDate != null) {
      try {
        endDate = DateTime.parse(project.expireDate!);
        dateText = _formatMonthYear(endDate);
      } catch (e) {
        // If parsing fails, try to get from tasks
        if (project.tasks.isNotEmpty) {
          try {
            final dates = project.tasks
                .map((task) => DateTime.parse(task.dueDate))
                .toList();
            endDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
            dateText = _formatMonthYear(endDate);
          } catch (e) {
            dateText = '';
          }
        }
      }
    } else if (project.tasks.isNotEmpty) {
      try {
        final dates = project.tasks
            .map((task) => DateTime.parse(task.dueDate))
            .toList();
        endDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
        dateText = _formatMonthYear(endDate);
      } catch (e) {
        dateText = '';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image on the left - Responsive sizing for small screens
            Builder(
              builder: (context) {
                // Use smaller image on very small screens
                final screenWidth = MediaQuery.of(context).size.width;
                final imageSize = screenWidth < 360 ? 90.0 : 100.0;
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    color: const Color(0xFFF3F4F6),
                    child: firstImageUrl != null && firstImageUrl.isNotEmpty
                        ? Image.network(
                            firstImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                  color: Color(0xFF9CA3AF),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6B7C32),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 24,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                );
              },
            ),
            // Content Column on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Title: "Project<<name>>" or "Projet<<name>>"
                    Text(
                      '${l10n.translate('project_label')}<<${project.title}>>',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Description/Tagline
                    Text(
                      tagline,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Progress Bar with Percentage and Date
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 200;
                        // On small screens, stack vertically; otherwise horizontal
                        if (isSmallScreen) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$completionPercentage%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  if (dateText.isNotEmpty) ...[
                                    const Spacer(),
                                    Text(
                                      dateText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completionPercentage / 100,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6B7C32),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              // Progress Percentage
                              Text(
                                '$completionPercentage%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Progress Bar
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: completionPercentage / 100,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6B7C32),
                                    ),
                                  ),
                                ),
                              ),
                              // Date on the right
                              if (dateText.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    dateText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

