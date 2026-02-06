import 'package:udb_association/src/features/news/models/news_model.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';

// Combined model to handle both news and events
class CombinedItemModel {
  final String id; // Prefixed with type to ensure uniqueness
  final String title;
  final String content;
  final String type; // 'news', 'announcement', 'event'
  final String scope; // 'global' or 'branch'
  final int? targetBranchId;
  final String image;
  final DateTime publishDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CombinedBranch? branch;
  final CombinedUser? user;

  // Event-specific fields (null for news)
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTimeString; // Time in HH:mm format or null
  final String? endTimeString; // Time in HH:mm format or null
  final String? location;
  final String? category;
  final String? latitude; // Event location latitude
  final String? longitude; // Event location longitude

  const CombinedItemModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.scope,
    this.targetBranchId,
    required this.image,
    required this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    this.branch,
    this.user,
    this.startDate,
    this.endDate,
    this.startTimeString,
    this.endTimeString,
    this.location,
    this.category,
    this.latitude,
    this.longitude,
  });

  // Factory method to create from NewsModel
  factory CombinedItemModel.fromNews(NewsModel news) {
    return CombinedItemModel(
      id: 'news_${news.id}',
      title: news.title,
      content: news.content,
      type: news.type,
      scope: news.scope,
      targetBranchId: news.targetBranchId,
      image: news.image,
      publishDate: news.publishDate,
      createdAt: news.createdAt,
      updatedAt: news.updatedAt,
      branch: news.branch != null
          ? CombinedBranch.fromNewsBranch(news.branch!)
          : null,
      user: CombinedUser.fromNewsUser(news.user),
    );
  }

  // Factory method to create from EventModel
  factory CombinedItemModel.fromEvent(EventModel event) {
    return CombinedItemModel(
      id: 'event_${event.id}',
      title: event.title,
      content: event.description,
      type: 'event',
      scope: event.scope,
      targetBranchId: event.targetBranchId,
      image: event.image,
      publishDate: event.startDate, // Use start date as publish date for events
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      branch: event.branch != null
          ? CombinedBranch.fromEventBranch(event.branch!)
          : null,
      user: null, // Events don't have user info in the current model
      startDate: event.startDate,
      endDate: event.endDate,
      startTimeString: event.startTimeString,
      endTimeString: event.endTimeString,
      location: event.location,
      category: event.category,
      latitude: event.latitude,
      longitude: event.longitude,
    );
  }

  // Helper getters
  String get subtitle => content;
  String get timeAgo => _getTimeAgo(publishDate);

  // Helper method to get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if this is an event
  bool get isEvent => type == 'event';

  // Check if this is news
  bool get isNews => type == 'news';

  // Check if this is an announcement
  bool get isAnnouncement => type == 'announcement';
}

// Combined branch model
class CombinedBranch {
  final int id;
  final String name;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CombinedBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CombinedBranch.fromNewsBranch(NewsBranch branch) {
    return CombinedBranch(
      id: branch.id,
      name: branch.name,
      address: branch.address,
      createdAt: branch.createdAt,
      updatedAt: branch.updatedAt,
    );
  }

  factory CombinedBranch.fromEventBranch(EventBranch branch) {
    return CombinedBranch(
      id: branch.id,
      name: branch.name,
      address: branch.address,
      createdAt: branch.createdAt,
      updatedAt: branch.updatedAt,
    );
  }
}

// Combined user model
class CombinedUser {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? provider;
  final String? providerId;
  final String role;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CombinedUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.provider,
    this.providerId,
    required this.role,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CombinedUser.fromNewsUser(NewsUser user) {
    return CombinedUser(
      id: user.id,
      name: user.name,
      email: user.email,
      emailVerifiedAt: user.emailVerifiedAt,
      provider: user.provider,
      providerId: user.providerId,
      role: user.role,
      isApproved: user.isApproved,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}

enum CombinedItemType { news, announcement, event }

extension CombinedItemTypeExtension on CombinedItemType {
  String get displayName {
    switch (this) {
      case CombinedItemType.news:
        return 'News';
      case CombinedItemType.announcement:
        return 'Announcements';
      case CombinedItemType.event:
        return 'Events';
    }
  }
}
