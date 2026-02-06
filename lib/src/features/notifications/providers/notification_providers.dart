import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/notifications/models/notification_model.dart';
import 'package:udb_association/src/features/notifications/services/notification_service.dart';
import 'package:udb_association/src/features/notifications/services/notification_storage.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification Storage Provider
final notificationStorageProvider = Provider<NotificationStorage>((ref) {
  return const NotificationStorage();
});

// Notifications Provider
final notificationsProvider = FutureProvider<NotificationResponse>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.fetchNotifications();
});

// Unread notifications count provider
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.fetchUnreadCount();
});

// Enhanced Notifications Provider with local read status
final enhancedNotificationsProvider = FutureProvider<List<NotificationModel>>((
  ref,
) async {
  final service = ref.read(notificationServiceProvider);
  final storage = ref.read(notificationStorageProvider);

  // Watch the profile provider to automatically refresh when user changes
  final profileAsync = ref.watch(profileProvider);

  return profileAsync.when(
    data: (user) async {
      // Fetch notifications from API
      final response = await service.fetchNotifications();

      // Determine current user's branch id
      final int? userBranchId = user.userBranchId;

      // Filter notifications: show if global (target_branch_id == null) or matches user's branch
      final filtered = response.data.where((n) {
        final tb = n.targetBranchId;
        if (tb == null) return true; // global
        if (userBranchId == null)
          return false; // user has no branch -> only globals
        return tb == userBranchId;
      }).toList();

      // Get read notification IDs from local storage for this user
      final readIds = await storage.getReadNotificationIds(user.email);

      // Update the isRead status based on local storage
      final enhancedNotifications = filtered.map((notification) {
        return NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          targetBranchId: notification.targetBranchId,
          isRead: readIds.contains(notification.id), // Use local storage status
          createdAt: notification.createdAt,
          updatedAt: notification.updatedAt,
        );
      }).toList();

      return enhancedNotifications;
    },
    loading: () async {
      // Return empty list while loading user
      return <NotificationModel>[];
    },
    error: (error, stack) async {
      // Return empty list on error
      return <NotificationModel>[];
    },
  );
});

// Mark as read provider (local storage only)
final markAsReadProvider = FutureProvider.family<void, int>((
  ref,
  notificationId,
) async {
  final service = ref.read(notificationServiceProvider);
  await service.markAsRead(notificationId);
  // Invalidate related providers
  ref.invalidate(enhancedNotificationsProvider);
  ref.invalidate(unreadNotificationsCountProvider);
});

// Logout provider that clears notification data when user logs out
final logoutProvider = FutureProvider<void>((ref) async {
  // Clear auth token
  await const TokenStorage().clearToken();

  // Invalidate all notification providers to clear cached data
  ref.invalidate(enhancedNotificationsProvider);
  ref.invalidate(notificationsProvider);

  // Note: We don't clear the notification storage as each user should keep their read status
  // If you want to clear all notification data on logout, uncomment the line below:
  // final storage = ref.read(notificationStorageProvider);
  // await storage.clearAllUsersReadNotifications();
});
