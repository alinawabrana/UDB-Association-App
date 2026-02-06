import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/features/news/models/combined_item_model.dart';
import 'package:udb_association/src/features/news/providers/news_provider.dart';
import 'package:udb_association/src/features/news/screens/news_detail_screen.dart';
import 'package:udb_association/src/features/news/screens/event_detail_from_news_screen.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/features/news/providers/news_provider.dart' as news_providers;
import 'package:udb_association/src/features/events/providers/event_provider.dart' as event_providers;
import '../../../../utils/constants/urls.dart';

class NewsSearchScreen extends ConsumerStatefulWidget {
  const NewsSearchScreen({super.key});

  @override
  ConsumerState<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends ConsumerState<NewsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(CombinedItemModel item, WidgetRef ref) async {
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
      // Handle news and announcements
      final newsAsync = ref.read(news_providers.newsProvider);
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
              debugPrint('News not found with id: $newsId');
            }
          }
        },
        loading: () {},
        error: (error, stack) {
          debugPrint('Error loading news: $error');
        },
      );
    }
  }

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
          appBar: AppBar(
            backgroundColor: const Color(0xFF6B7A47),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.translate('news_search_hint'),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
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
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          body: combinedAsync.when(
            data: (items) {
              List<CombinedItemModel> filteredItems = items;

              // Filter by branch
              if (userBranchId != null) {
                filteredItems = items.where((item) {
                  if (item.scope == 'global') {
                    return true;
                  }
                  if (item.scope == 'branch') {
                    return item.targetBranchId == userBranchId;
                  }
                  return false;
                }).toList();
              }

              // Apply filter if selected
              if (filterState.selectedFilter != null) {
                filteredItems = filteredItems.where((item) {
                  switch (filterState.selectedFilter!) {
                    case CombinedItemType.news:
                      return item.type == 'news';
                    case CombinedItemType.event:
                      return item.type == 'event';
                    case CombinedItemType.announcement:
                      return item.type == 'announcement';
                  }
                }).toList();
              }

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                filteredItems = filteredItems.where((item) {
                  final title = item.title.toLowerCase();
                  final content = item.content.toLowerCase();
                  return title.contains(_searchQuery) ||
                      content.contains(_searchQuery);
                }).toList();
              }

              if (filteredItems.isEmpty) {
                return Center(
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
                        _searchQuery.isEmpty
                            ? l10n.translate('news_search_start')
                            : l10n.translate('news_search_no_results'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final allowEngagement =
                  userRole != 'vendor' &&
                  !(userRole == 'user' && !isSpecialUser);

              return ListView.builder(
                padding: const EdgeInsets.all(17),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildNewsCard(item, allowEngagement: allowEngagement),
                  );
                },
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

  Widget _buildNewsCard(
    CombinedItemModel item, {
    required bool allowEngagement,
  }) {
    final l10n = context.l10n;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _navigateToDetail(item, ref),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (item.image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  ApiUrls.getMediaUrl(item.image),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    _formatDateForCard(item, l10n),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF60A5FA),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Content preview
                  Text(
                    item.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (allowEngagement) ...[
                    const SizedBox(height: 12),
                    // Engagement buttons
                    Row(
                      children: [
                        // Like button would go here
                        const SizedBox(width: 8),
                        // Comment button would go here
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
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
      return DateFormat('d MMMM yyyy', localeTag).format(item.publishDate).toUpperCase();
    }
  }
}

