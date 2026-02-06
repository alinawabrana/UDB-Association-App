import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import '../../auth/provider/auth_providers.dart';
import '../../branches/providers/branch_users_provider.dart';
import '../../../../utils/constants/urls.dart';
import '../../../common/localization/app_localizations.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(profileProvider);

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

    // Calculate progress percentage from tasks
    final totalTasks = widget.project.tasks.length;
    final completedTasks = widget.project.tasks
        .where((task) => task.status == 'done')
        .length;
    final progressPercentage = totalTasks > 0
        ? (completedTasks / totalTasks * 100).round()
        : 0;

    // Get start date (use issue_date from API, fallback to createdAt)
    final startDate = _parseDate(widget.project.issueDate ?? widget.project.createdAt);

    // Get end date (use expire_date from API, fallback to calculated date)
    DateTime? endDate;
    if (widget.project.expireDate != null) {
      endDate = _parseDate(widget.project.expireDate!);
    } else if (widget.project.tasks.isNotEmpty) {
      try {
        final dates = widget.project.tasks
            .map((task) => DateTime.parse(task.dueDate))
            .toList();
        endDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
      } catch (e) {
        // If parsing fails, use fallback
        endDate = startDate?.add(const Duration(days: 30));
      }
    } else {
      endDate = startDate?.add(const Duration(days: 30));
    }

    // Use tagline from API, fallback to first sentence of description
    final tagline = widget.project.tagline ??
        (widget.project.description.split('.').isNotEmpty &&
                widget.project.description.split('.')[0].trim().isNotEmpty
            ? widget.project.description.split('.')[0].trim()
            : widget.project.description);

    // Get images from API and convert to full URLs
    final imageUrls = (widget.project.images ?? [])
        .map((path) => ApiUrls.getMediaUrl(path))
        .where((url) => url.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7C32),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: null,
          title: Text(
            widget.project.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title
            Text(
              '${context.l10n.translate('project_label')}<<${widget.project.title}>>',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              tagline,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            // Progress Percentage and Bar
            Row(
              children: [
                Text(
                  '$progressPercentage%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      minHeight: 15,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B7C32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Image Carousel
            _ProjectImageCarousel(
              images: imageUrls,
            ),
            const SizedBox(height: 20),
            // Description with Read More
            _ExpandableDescription(
              description: widget.project.description,
              isExpanded: _isDescriptionExpanded,
              readMoreText: context.l10n.translate('read_more'),
              readLessText: context.l10n.translate('read_less'),
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
            ),
            const SizedBox(height: 20),
            // Start Date and End Date Row
            Row(
              children: [
                Expanded(
                  child: _DateCard(
                    label: context.l10n.translate('project_start_date'),
                    date: startDate,
                    iconColor: Colors.yellow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateCard(
                    label: context.l10n.translate('project_end_date'),
                    date: endDate,
                    iconColor: const Color(0xFF6B7C32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // My Tasks Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userRole?.toLowerCase() == 'manager'
                        ? context.l10n.translate('all_tasks')
                        : context.l10n.translate('my_tasks'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MyTasksList(
                    userRole: userRole,
                    projectId: widget.project.id,
                    branchId: widget.project.branchId,
                    currentUserId: currentUserId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}

class _ProjectImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ProjectImageCarousel({required this.images});

  @override
  State<_ProjectImageCarousel> createState() => _ProjectImageCarouselState();
}

class _ProjectImageCarouselState extends State<_ProjectImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no images, show placeholder
    if (widget.images.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Left arrow
          if (widget.images.length > 1 && _currentIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          // Right arrow
          if (widget.images.length > 1 &&
              _currentIndex < widget.images.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
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

class _ExpandableDescription extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final String readMoreText;
  final String readLessText;
  final VoidCallback onTap;

  const _ExpandableDescription({
    required this.description,
    required this.isExpanded,
    required this.readMoreText,
    required this.readLessText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate max lines (6.5 lines)
    final textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1F2937),
      height: 1.5,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: description, style: textStyle),
      maxLines: 6,
      textDirection: Directionality.of(context),
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final hasOverflow = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: textStyle,
          maxLines: isExpanded ? null : 6,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (hasOverflow || description.length > 200)
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                isExpanded ? readLessText : readMoreText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7C32),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color iconColor;

  const _DateCard({
    required this.label,
    required this.date,
    required this.iconColor,
  });

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return 'N/A';
    final l10n = context.l10n;
    final locale = l10n.locale;
    final dateFormat = DateFormat('dd MMMM yyyy', locale.toLanguageTag());
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(context, date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyTasksList extends ConsumerWidget {
  final String? userRole;
  final int projectId;
  final int branchId;
  final int? currentUserId;

  const _MyTasksList({
    this.userRole,
    required this.projectId,
    required this.branchId,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔍 === _MyTasksList build method called ===');
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (tasksResponse) {
        print('✅ Tasks data received successfully');
        print('📊 Total tasks count: ${tasksResponse.data.length}');

        final allTasks = tasksResponse.data;
        print('🎯 Current project ID: $projectId');

        // Filter tasks based on project and user role
        final projectTasks = allTasks.where((task) {
          final taskProjectId = task.project?.id;
          print(
            '🔍 Task ${task.id} project ID: $taskProjectId, assigned to: ${task.assignedTo}',
          );

          // First filter by project ID
          if (taskProjectId != projectId) {
            return false;
          }

          // For managers: show all tasks in the project
          if (userRole?.toLowerCase() == 'manager') {
            print('👑 Manager view: showing all tasks for project');
            return true;
          }

          // For members: show only tasks assigned to current user
          if (userRole?.toLowerCase() == 'member' && currentUserId != null) {
            final isAssignedToUser = task.assignedTo == currentUserId;
            print('👤 Member view: task assigned to user? $isAssignedToUser');
            return isAssignedToUser;
          }

          // Default: show all tasks (fallback)
          return true;
        }).toList();

        print('📋 Filtered tasks count: ${projectTasks.length}');

        if (projectTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                userRole?.toLowerCase() == 'manager'
                    ? context.l10n.translate('tasks_no_tasks_found')
                    : context.l10n.translate('tasks_no_tasks_assigned'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projectTasks.length,
          itemBuilder: (context, index) {
            final task = projectTasks[index];
            return _TaskCard(
              task: task,
              userRole: userRole,
              branchId: branchId,
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF6B7C32)),
        ),
      ),
      error: (error, stackTrace) {
        print('❌ === TASKS ERROR IN PROJECT DETAIL ===');
        print('❌ Error: $error');
        print('❌ Stack trace: $stackTrace');
        print('❌ Error type: ${error.runtimeType}');

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.translate('tasks_failed_to_load').replaceAll('{error}', error.toString()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    print('🔄 Retrying tasks...');
                    ref.invalidate(tasksProvider);
                  },
                  child: Text(context.l10n.translate('retry')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final String? userRole;
  final int branchId; // Need branchId to fetch branch users

  const _TaskCard({required this.task, this.userRole, required this.branchId});

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  @override
  Widget build(BuildContext context) {
    // Fetch branch users for the project's branch
    final branchUsersAsync = ref.watch(branchUsersProvider(widget.branchId));

    // Create a map of user ID to profile image URL
    final Map<int, String?> userImageMap = branchUsersAsync.when(
      data: (branchUsers) {
        final map = <int, String?>{};
        for (final user in branchUsers) {
          // Get profile image from profile_image property using utils function
          String? profileImageUrl;

          // Check profile_image in priority order: profile -> memberProfile -> managerProfile
          if (user.profile?.profileImage != null &&
              user.profile!.profileImage!.isNotEmpty) {
            profileImageUrl = ApiUrls.getProfileImageUrl(
              user.profile!.profileImage,
            );
          } else if (user.memberProfile?.profileImage != null &&
              user.memberProfile!.profileImage!.isNotEmpty) {
            profileImageUrl = ApiUrls.getProfileImageUrl(
              user.memberProfile!.profileImage,
            );
          } else if (user.managerProfile?.profileImage != null &&
              user.managerProfile!.profileImage!.isNotEmpty) {
            profileImageUrl = ApiUrls.getProfileImageUrl(
              user.managerProfile!.profileImage,
            );
          }
          map[user.id] = profileImageUrl;
        }
        return map;
      },
      loading: () => <int, String?>{},
      error: (_, __) => <int, String?>{},
    );

    // Get assignee image URL
    final assigneeImageUrl = widget.task.assignee != null
        ? userImageMap[widget.task.assignee!.id]
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              _StatusChip(status: widget.task.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.task.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                '${context.l10n.translate('due')} ${_formatDate(widget.task.dueDate)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              if (widget.task.assignee != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: assigneeImageUrl != null && assigneeImageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            assigneeImageUrl,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF6B7C32),
                                ),
                                child: Text(
                                  widget.task.assignee!.name.isNotEmpty
                                      ? widget.task.assignee!.name[0]
                                            .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE5E7EB),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF6B7C32),
                          ),
                          child: Center(
                            child: Text(
                              widget.task.assignee!.name.isNotEmpty
                                  ? widget.task.assignee!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.task.assignee!.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Only show status update buttons for non-managers
          if (widget.userRole?.toLowerCase() != 'manager')
            _StatusUpdateButtons(task: widget.task),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'todo':
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'in_progress':
        backgroundColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFFCA8A04);
        break;
      case 'to_verify':
        backgroundColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFEA580C);
        break;
      case 'done':
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _StatusUpdateButtons extends ConsumerStatefulWidget {
  final TaskModel task;

  const _StatusUpdateButtons({required this.task});

  @override
  ConsumerState<_StatusUpdateButtons> createState() =>
      _StatusUpdateButtonsState();
}

class _StatusUpdateButtonsState extends ConsumerState<_StatusUpdateButtons> {
  @override
  Widget build(BuildContext context) {
    final taskStatusUpdateAsync = ref.watch(taskStatusUpdateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.translate('tasks_update_status'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusButton(
              label: context.l10n.translate('status_todo'),
              status: 'todo',
              currentStatus: widget.task.status,
              onTap: () async => await _updateStatus(ref, 'todo'),
              isLoading: taskStatusUpdateAsync.isLoading,
            ),
            _StatusButton(
              label: context.l10n.translate('status_in_progress'),
              status: 'in_progress',
              currentStatus: widget.task.status,
              onTap: () async => await _updateStatus(ref, 'in_progress'),
              isLoading: taskStatusUpdateAsync.isLoading,
            ),
            _StatusButton(
              label: context.l10n.translate('status_to_verify'),
              status: 'to_verify',
              currentStatus: widget.task.status,
              onTap: () async => await _updateStatus(ref, 'to_verify'),
              isLoading: taskStatusUpdateAsync.isLoading,
            ),
            _StatusButton(
              label: context.l10n.translate('status_done'),
              status: 'done',
              currentStatus: widget.task.status,
              onTap: () async => await _updateStatus(ref, 'done'),
              isLoading: taskStatusUpdateAsync.isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String newStatus) async {
    try {
      // Update task status via API
      await ref
          .read(taskStatusUpdateProvider.notifier)
          .updateTaskStatus(widget.task.id, newStatus);

      // Refresh both tasks and projects providers to show updated data
      ref.invalidate(tasksProvider);
      ref.invalidate(projectsProvider);

      print('✅ Task status updated successfully, providers refreshed');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.translate('tasks_status_updated').replaceAll('{status}', newStatus.replaceAll('_', ' ')),
            ),
            backgroundColor: const Color(0xFF6B7C32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to update task status: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('tasks_status_update_failed').replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String status;
  final String currentStatus;
  final Future<void> Function() onTap;
  final bool isLoading;

  const _StatusButton({
    required this.label,
    required this.status,
    required this.currentStatus,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentStatus = currentStatus == status;
    final isDisabled = isLoading || isCurrentStatus;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentStatus
              ? const Color(0xFF6B7C32)
              : isDisabled
              ? const Color(0xFFF3F4F6)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentStatus
                ? const Color(0xFF6B7C32)
                : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6B7C32),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCurrentStatus
                      ? Colors.white
                      : isDisabled
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
      ),
    );
  }
}
