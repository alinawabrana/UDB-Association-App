import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/news/models/news_model.dart';
import 'package:udb_association/src/features/news/models/combined_item_model.dart';
import 'package:udb_association/src/features/news/services/news_service.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/src/features/events/services/event_service.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/news/models/comment_model.dart';
import 'package:udb_association/src/features/news/services/comment_service.dart';
import 'package:udb_association/src/features/news/models/like_model.dart';
import 'package:udb_association/src/features/news/services/like_service.dart';

// Combined filter state
class CombinedFilterState {
  final CombinedItemType? selectedFilter;

  const CombinedFilterState({this.selectedFilter});

  CombinedFilterState copyWith({
    CombinedItemType? selectedFilter,
    bool clearFilter = false,
  }) {
    return CombinedFilterState(
      selectedFilter: clearFilter
          ? null
          : (selectedFilter ?? this.selectedFilter),
    );
  }
}

// Combined filter provider
final combinedFilterProvider =
    StateNotifierProvider<CombinedFilterNotifier, CombinedFilterState>((ref) {
      return CombinedFilterNotifier();
    });

class CombinedFilterNotifier extends StateNotifier<CombinedFilterState> {
  CombinedFilterNotifier() : super(const CombinedFilterState());

  void setFilter(CombinedItemType? filter) {
    state = state.copyWith(selectedFilter: filter, clearFilter: filter == null);
  }
}

// NewsService Provider
final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

// EventService Provider
final eventServiceProvider = Provider<EventService>((ref) => EventService());

final commentServiceProvider = Provider<CommentService>(
  (ref) => CommentService(),
);

final likeServiceProvider = Provider<LikeService>((ref) => LikeService());

// News data provider - fetches from API
final newsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final service = ref.read(newsServiceProvider);
  final token = ref.read(authTokenProvider);

  if (token == null) {
    throw Exception("Not logged in");
  }

  return await service.fetchNews(token);
});

// Events data provider - fetches from API
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  final token = ref.read(authTokenProvider);

  if (token == null) {
    throw Exception("Not logged in");
  }

  return await service.fetchEvents(token);
});

// Combined data provider - merges news and events
final combinedDataProvider = FutureProvider<List<CombinedItemModel>>((
  ref,
) async {
  final newsService = ref.read(newsServiceProvider);
  final eventService = ref.read(eventServiceProvider);
  final token = ref.read(authTokenProvider);

  if (token == null) {
    throw Exception("Not logged in");
  }

  // Fetch both news and events
  final results = await Future.wait([
    newsService.fetchNews(token),
    eventService.fetchEvents(token),
  ]);

  final news = results[0] as List<NewsModel>;
  final events = results[1] as List<EventModel>;

  // Convert news to combined items
  final newsItems = news.map((n) => CombinedItemModel.fromNews(n)).toList();

  // Convert events to combined items
  final eventItems = events.map((e) => CombinedItemModel.fromEvent(e)).toList();

  // Combine and sort: announcements first, then by publish date (newest first)
  final combined = [...newsItems, ...eventItems];

  // Sort: announcements first, then by publish date (newest first)
  combined.sort((a, b) {
    // If one is announcement and other is not, announcement comes first
    if (a.isAnnouncement && !b.isAnnouncement) return -1;
    if (!a.isAnnouncement && b.isAnnouncement) return 1;
    // Otherwise sort by publish date (newest first)
    return b.publishDate.compareTo(a.publishDate);
  });

  return combined;
});

final commentsProvider = FutureProvider.family<CommentPage, CommentRequest>((
  ref,
  request,
) async {
  final token = ref.read(authTokenProvider);
  if (token == null) {
    throw Exception('Not logged in');
  }
  final service = ref.read(commentServiceProvider);
  return service.fetchComments(
    token: token,
    targetType: request.targetType,
    targetId: request.targetId,
    page: request.page,
  );
});

final likeStatusProvider = StateNotifierProvider.autoDispose
    .family<LikeStatusNotifier, AsyncValue<LikeStatus>, LikeRequest>(
      (ref, request) => LikeStatusNotifier(ref, request),
    );

class LikeStatusNotifier extends StateNotifier<AsyncValue<LikeStatus>> {
  LikeStatusNotifier(this._ref, this._request)
    : super(const AsyncValue.loading()) {
    _fetch();
  }

  final Ref _ref;
  final LikeRequest _request;

  Future<void> _fetch() async {
    final token = _ref.read(authTokenProvider);
    if (token == null) {
      state = AsyncValue.error(
        Exception('Not authenticated'),
        StackTrace.current,
      );
      return;
    }

    final service = _ref.read(likeServiceProvider);
    try {
      final status = await service.fetchStatus(
        token: token,
        targetType: _request.targetType,
        targetId: _request.targetId,
      );
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike() async {
    final currentState = state;
    final current =
        currentState.value ?? const LikeStatus(count: 0, isLiked: false);

    if (!current.supportsLike) {
      throw Exception('Likes are not supported for this item.');
    }

    final token = _ref.read(authTokenProvider);
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final service = _ref.read(likeServiceProvider);

    final delta = current.isLiked ? -1 : 1;
    final newCount = current.count + delta;
    final optimistic = current.copyWith(
      isLiked: !current.isLiked,
      count: newCount < 0 ? 0 : newCount,
    );

    state = AsyncValue.data(optimistic);

    try {
      if (current.isLiked) {
        await service.unlike(
          token: token,
          targetType: _request.targetType,
          targetId: _request.targetId,
        );
      } else {
        await service.like(
          token: token,
          targetType: _request.targetType,
          targetId: _request.targetId,
        );
      }
      final refreshed = await service.fetchStatus(
        token: token,
        targetType: _request.targetType,
        targetId: _request.targetId,
      );
      state = AsyncValue.data(refreshed);
    } catch (e, _) {
      state = currentState;
      throw e;
    }
  }
}

// Filtered combined provider with scope-based filtering
final filteredCombinedProvider = Provider<List<CombinedItemModel>>((ref) {
  final combinedAsync = ref.watch(combinedDataProvider);
  final filterState = ref.watch(combinedFilterProvider);
  final userProfileAsync = ref.watch(profileProvider);

  return combinedAsync.when(
    data: (items) {
      // Filter by user access (scope-based filtering)
      final accessibleItems = _filterCombinedByScope(
        items,
        userProfileAsync.value,
      );

      // Filter by type
      if (filterState.selectedFilter != null) {
        final filteredItems = accessibleItems.where((item) {
          switch (filterState.selectedFilter!) {
            case CombinedItemType.news:
              return item.type == 'news';
            case CombinedItemType.announcement:
              return item.type == 'announcement';
            case CombinedItemType.event:
              return item.type == 'event';
          }
        }).toList();
        return filteredItems;
      }

      return accessibleItems;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Helper function to filter combined items based on scope and user branch membership
List<CombinedItemModel> _filterCombinedByScope(
  List<CombinedItemModel> items,
  dynamic user,
) {
  if (user == null) {
    return [];
  }

  // Get user's branch ID
  final userBranchId = user.branchId;

  final filteredItems = items.where((item) {
    // If scope is global, show to everyone
    if (item.scope == 'global') {
      return true;
    }

    // If scope is branch, only show to members of that branch
    if (item.scope == 'branch') {
      final shouldShow =
          userBranchId != null && userBranchId == item.targetBranchId;
      return shouldShow;
    }

    return false;
  }).toList();

  return filteredItems;
}
