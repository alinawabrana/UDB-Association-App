import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/widgets/app_drawer.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/router/app_router.dart';
import '../models/combined_item_model.dart';
import '../providers/news_provider.dart';
import '../../../../utils/constants/urls.dart';
import '../../auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/news/models/comment_model.dart';
import 'package:udb_association/src/features/news/models/like_model.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/news/screens/news_detail_screen.dart';
import 'package:udb_association/src/features/news/screens/event_detail_from_news_screen.dart';
import 'package:udb_association/src/features/events/providers/event_provider.dart'
    as event_providers;

class _CustomNewsAppBar extends ConsumerWidget {
  final VoidCallback onFilterTap;
  final bool isSpecialUser;

  const _CustomNewsAppBar({
    required this.onFilterTap,
    required this.isSpecialUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unreadNotificationsAsync = ref.watch(
      unreadNotificationsCountProvider,
    );

    return SafeArea(
      bottom: false,
      top: false,
      child: Container(
        color: const Color(0xFF6B7A47),
        padding: const EdgeInsets.only(top: 25, bottom: 12, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.translate('news_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isSpecialUser)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          final targetContext =
                              AppRouteNames.rootKey.currentContext ?? context;
                          targetContext.goNamed(
                            AppRouteNames.userNotifications,
                          );
                        },
                        icon: const Icon(
                          Iconsax.notification5,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      unreadNotificationsAsync.when(
                        data: (count) => count > 0
                            ? Positioned(
                                right: 6,
                                top: 8,
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
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouteNames.newsSearch);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.translate('news_search_hint'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      size: 22,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  int selectedChipIndex = 0;
  final List<String> chipLabels = ['All', 'Announcements', 'News'];

  @override
  Widget build(BuildContext context) {
    final combinedAsync = ref.watch(combinedDataProvider);
    final filterState = ref.watch(combinedFilterProvider);
    final userProfileAsync = ref.watch(profileProvider);
    final subscriptionStatusAsync = ref.watch(
      userHasApprovedSubscriptionProvider,
    );
    final isSpecialUser = subscriptionStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final l10n = context.l10n;

    return userProfileAsync.when(
      data: (user) {
        final userBranchId = user.branchId;
        final userRole = user.role?.toLowerCase() ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          drawer: const AppDrawer(),
          resizeToAvoidBottomInset: true,
          appBar: null,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                _CustomNewsAppBar(
                  onFilterTap: () => _showFilterBottomSheet(context, l10n),
                  isSpecialUser: isSpecialUser,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0x00000000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: combinedAsync.when(
                        data: (items) {
                          List<CombinedItemModel> filteredItems = items;
                          
                          // Always exclude events from news screen
                          filteredItems = items.where((item) => item.type != 'event').toList();
                          
                          if (userBranchId != null) {
                            filteredItems = filteredItems.where((item) {
                              if (item.scope == 'global') {
                                return true;
                              }
                              if (item.scope == 'branch') {
                                return item.targetBranchId == userBranchId;
                              }
                              return false;
                            }).toList();
                          }

                          // Separate announcements and news
                          final announcements = filteredItems
                              .where((item) => item.type == 'announcement')
                              .toList();
                          final newsItems = filteredItems
                              .where((item) => item.type == 'news')
                              .toList();

                          // Sort by publish date (most recent first)
                          announcements.sort((a, b) => b.publishDate.compareTo(a.publishDate));
                          newsItems.sort((a, b) => b.publishDate.compareTo(a.publishDate));

                          final allowEngagement =
                              userRole != 'vendor' &&
                              !(userRole == 'user' && !isSpecialUser);

                          final keyboardHeight = MediaQuery.of(
                            context,
                          ).viewInsets.bottom;

                          // If filter is selected, show filtered list
                          if (filterState.selectedFilter != null) {
                            List<CombinedItemModel> filteredList = [];
                            switch (filterState.selectedFilter!) {
                              case CombinedItemType.news:
                                filteredList = newsItems;
                                break;
                              case CombinedItemType.announcement:
                                filteredList = announcements;
                                break;
                              case CombinedItemType.event:
                                filteredList = []; // Events not shown
                                break;
                            }

                            if (filteredList.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.translate('news_empty'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: keyboardHeight > 0
                                    ? keyboardHeight + 16
                                    : 80,
                              ),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return Column(
                                  children: [
                                    _buildNewsCard(
                                      item,
                                      allowEngagement: allowEngagement,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              },
                            );
                          }

                          // "All" filter selected - show two sections
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(
                              bottom: keyboardHeight > 0
                                  ? keyboardHeight + 16
                                  : 80,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Announcements Section
                                if (announcements.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      l10n.translate('news_filter_announcements'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Show only 3 most recent announcements
                                  ...announcements.take(3).map((item) {
                                    return Column(
                                      children: [
                                        _buildNewsCard(
                                          item,
                                          allowEngagement: allowEngagement,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 24),
                                ],

                                // News Section
                                if (newsItems.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      l10n.translate('news_filter_news'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Show all news items
                                  ...newsItems.map((item) {
                                    return Column(
                                      children: [
                                        _buildNewsCard(
                                          item,
                                          allowEngagement: allowEngagement,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  }),
                                ],

                                // Empty state if both are empty
                                if (announcements.isEmpty && newsItems.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        l10n.translate('news_empty'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6B7A47),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('news_failed_to_load'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.invalidate(combinedDataProvider);
                                },
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.translate('retry')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B7A47),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            l10n.translate(
              'profile_failed_to_load',
              params: {'error': error.toString()},
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDateForCard(CombinedItemModel item, AppLocalizations l10n) {
    final localeTag = l10n.locale.toLanguageTag();

    if (item.isEvent) {
      // For events, format as "start date At Time"
      final startDate = item.startDate ?? item.publishDate;
      final dateStr = DateFormat(
        'd MMMM yyyy',
        localeTag,
      ).format(startDate).toUpperCase();

      // Use startTimeString if available, otherwise extract from DateTime
      String timeStr;
      if (item.startTimeString != null && item.startTimeString!.isNotEmpty) {
        timeStr = item.startTimeString!;
      } else {
        // Fallback to extracting time from DateTime
        timeStr = DateFormat('HH:mm', localeTag).format(startDate);
      }

      final atLabel = l10n.translate('detail_at');

      return '$dateStr $atLabel $timeStr';
    } else {
      // For news/announcements, format as "6 DECEMBER 2023"
      return DateFormat(
        'd MMMM yyyy',
        localeTag,
      ).format(item.publishDate).toUpperCase();
    }
  }

  void _navigateToDetail(CombinedItemModel item) async {
    if (item.isEvent) {
      // Fetch the event model
      final eventsAsync = ref.read(event_providers.eventsProvider);
      await eventsAsync.when(
        data: (events) {
          final eventId = int.tryParse(item.id.replaceFirst('event_', ''));
          if (eventId != null) {
            try {
              final event = events.firstWhere((e) => e.id == eventId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailFromNewsScreen(event: event),
                ),
              );
            } catch (e) {
              debugPrint('Event not found with id: $eventId');
            }
          }
        },
        loading: () {},
        error: (error, stack) {
          debugPrint('Error loading events: $error');
        },
      );
    } else {
      // Handle news and announcements (both have news_ prefix)
      final newsAsync = ref.read(newsProvider);
      await newsAsync.when(
        data: (newsList) {
          final newsId = int.tryParse(item.id.replaceFirst('news_', ''));
          if (newsId != null) {
            try {
              final news = newsList.firstWhere((n) => n.id == newsId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(news: news),
                ),
              );
            } catch (e) {
              debugPrint('News/Announcement not found with id: $newsId');
            }
          } else {
            debugPrint('Could not parse news ID from: ${item.id}');
          }
        },
        loading: () {},
        error: (error, stack) {
          debugPrint('Error loading news: $error');
        },
      );
    }
  }

  Widget _buildNewsCard(
    CombinedItemModel item, {
    required bool allowEngagement,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000), // Black with 5% opacity
              offset: Offset(0, 1), // x=0, y=1
              blurRadius: 2, // blur
              spreadRadius: 0, // no spread
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                ApiUrls.getMediaUrl(item.image),
                width: 100,
                height: 140,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 140,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B7A47),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 140,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF9CA3AF),
                    size: 32,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date
                          Text(
                            _formatDateForCard(item, context.l10n),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(
                                0xFF60A5FA,
                              ), // Light blue color like events
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              item.content,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom row with engagement buttons
                    if (allowEngagement)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LikeButton(item: item),
                            const SizedBox(width: 4),
                            _buildCommentButton(item, enabled: allowEngagement),
                          ],
                        ),
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

  Widget _buildCommentButton(CombinedItemModel item, {bool enabled = true}) {
    if (!enabled) return const SizedBox.shrink();

    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _showCommentsSheet(item),
      icon: const Icon(Icons.mode_comment_outlined, size: 16),
      label: Text(context.l10n.translate('news_comments')),
    );
  }

  void _showFilterBottomSheet(BuildContext context, AppLocalizations l10n) {
    final filterState = ref.read(combinedFilterProvider);
    final currentFilterIndex = () {
      if (filterState.selectedFilter == null) return 0;
      switch (filterState.selectedFilter!) {
        case CombinedItemType.announcement:
          return 1;
        case CombinedItemType.news:
          return 2;
        case CombinedItemType.event:
          return 0; // Events filter not available, default to All
      }
    }();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.translate('news_filter_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),
                ...chipLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = currentFilterIndex == index;

                  final displayLabel = () {
                    switch (label) {
                      case 'Announcements':
                        return l10n.translate('news_filter_announcements');
                      case 'News':
                        return l10n.translate('news_filter_news');
                      default:
                        return l10n.translate('news_filter_all');
                    }
                  }();

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedChipIndex = index;
                      });
                      CombinedItemType? filter;
                      switch (index) {
                        case 1:
                          filter = CombinedItemType.announcement;
                          break;
                        case 2:
                          filter = CombinedItemType.news;
                          break;
                        default:
                          filter = null; // All (no filter)
                      }
                      ref
                          .read(combinedFilterProvider.notifier)
                          .setFilter(filter);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6B7A47).withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6B7A47)
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                              color: isSelected
                                  ? const Color(0xFF6B7A47)
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              displayLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF6B7A47)
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsSheet(CombinedItemModel item) {
    final targetId = _parseCombinedItemId(item.id);
    if (targetId == null) {
      SnackbarUtils.showError(
        context,
        message: 'Unable to open comments for this item.',
      );
      return;
    }

    final targetType = item.isEvent
        ? ContentTargetType.event
        : ContentTargetType.news;

    context.pushNamed(
      AppRouteNames.comments,
      extra: {'item': item, 'targetId': targetId, 'targetType': targetType},
    );
  }
}

int? _parseCombinedItemId(String rawId) {
  final parts = rawId.split('_');
  if (parts.length != 2) {
    return null;
  }
  return int.tryParse(parts[1]);
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({
    required this.item,
    required this.targetId,
    required this.targetType,
    required this.scrollController,
  });

  final CombinedItemModel item;
  final int targetId;
  final ContentTargetType targetType;
  final ScrollController scrollController;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = CommentRequest(
      targetType: widget.targetType,
      targetId: widget.targetId,
    );
    final commentsAsync = ref.watch(commentsProvider(request));

    return SafeArea(
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Comments list - flexible
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: commentsAsync.when(
                data: (page) {
                  final comments = page.comments;
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.translate('news_no_comments'),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            l10n.translate(
                              'news_comments_count',
                              params: {'count': '${page.total}'},
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: widget.scrollController,
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _CommentTile(comment: comment);
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Comment composer - fixed at bottom
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildComposer(context, l10n, request),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(
    BuildContext context,
    AppLocalizations l10n,
    CommentRequest request,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.translate('news_add_comment_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () => _submitComment(context, request),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B7A47),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.9),
                  ),
                )
              : Text(l10n.translate('news_post_comment')),
        ),
      ],
    );
  }

  Future<void> _submitComment(
    BuildContext context,
    CommentRequest request,
  ) async {
    final commentText = _controller.text.trim();
    
    print('💬 [NEWS SCREEN] Submitting comment...');
    print('   Target Type: ${request.targetType.name}');
    print('   Target ID: ${request.targetId}');
    print('   Comment Text: $commentText');
    print('   Comment Length: ${commentText.length}');
    
    if (commentText.isEmpty) {
      print('⚠️ [NEWS SCREEN] Comment is empty, showing warning');
      SnackbarUtils.showWarning(
        context,
        message: context.l10n.translate('news_comment_empty_error'),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = ref.read(authTokenProvider);
      if (token == null) {
        print('❌ [NEWS SCREEN] Not authenticated');
        throw Exception('Not authenticated');
      }
      
      print('💬 [NEWS SCREEN] Calling comment service...');
      final service = ref.read(commentServiceProvider);
      final createdComment = await service.createComment(
        token: token,
        targetType: request.targetType,
        targetId: request.targetId,
        comment: commentText,
      );
      
      print('💬 [NEWS SCREEN] Comment created successfully!');
      print('   Comment ID: ${createdComment.id}');
      print('   Author: ${createdComment.authorName}');
      
      if (!mounted) return;
      _controller.clear();
      ref.invalidate(commentsProvider(request));
      print('💬 [NEWS SCREEN] Comments list invalidated, refreshing...');
      
      SnackbarUtils.showSuccess(
        context,
        message: context.l10n.translate('news_comment_posted'),
      );
    } catch (e) {
      print('❌ [NEWS SCREEN] Error submitting comment:');
      print('   Error: $e');
      if (!mounted) return;
      SnackbarUtils.showError(context, message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        print('💬 [NEWS SCREEN] Comment submission completed');
      }
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF6B7A47),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (comment.formattedDate.isNotEmpty)
                      Text(
                        comment.formattedDate,
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
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  const _LikeButton({required this.item});

  final CombinedItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetId = _parseCombinedItemId(item.id);
    if (targetId == null) {
      return const SizedBox.shrink();
    }

    final request = LikeRequest(
      targetType: item.isEvent
          ? ContentTargetType.event
          : ContentTargetType.news,
      targetId: targetId,
    );

    final likeState = ref.watch(likeStatusProvider(request));
    final l10n = context.l10n;

    return likeState.when(
      data: (status) {
        final icon = status.isLiked ? Icons.favorite : Icons.favorite_border;
        final iconColor = status.isLiked
            ? const Color(0xFFE11D48)
            : const Color(0xFF6B7280);
        final labelColor = status.supportsLike
            ? iconColor
            : const Color(0xFF9CA3AF);
        final countText = status.supportsLike ? status.count.toString() : '--';

        return TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: status.supportsLike
              ? () async {
                  try {
                    await ref
                        .read(likeStatusProvider(request).notifier)
                        .toggleLike();
                  } catch (e) {
                    final message =
                        e.toString().toLowerCase().contains('not supported')
                        ? l10n.translate('news_like_unsupported')
                        : l10n.translate('news_like_error');
                    SnackbarUtils.showError(context, message: message);
                  }
                }
              : null,
          icon: Icon(icon, size: 18, color: iconColor),
          label: Text(
            countText,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, _) => TextButton.icon(
        onPressed: () => ref.invalidate(likeStatusProvider(request)),
        icon: const Icon(Icons.refresh, size: 18, color: Color(0xFFB91C1C)),
        label: Text(
          l10n.translate('retry'),
          style: const TextStyle(
            color: Color(0xFFB91C1C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
