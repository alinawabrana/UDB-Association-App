import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorage {
  static const String _readNotificationsKey = 'read_notifications';

  const NotificationStorage();

  /// Get user-specific key for read notifications
  String _getUserKey(String userEmail) {
    return '${_readNotificationsKey}_$userEmail';
  }

  /// Get all read notification IDs for a specific user
  Future<Set<int>> getReadNotificationIds(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(userEmail);
    final readIds = prefs.getStringList(userKey) ?? [];
    return readIds.map((id) => int.parse(id)).toSet();
  }

  /// Mark a notification as read for a specific user
  Future<void> markAsRead(int notificationId, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = await getReadNotificationIds(userEmail);
    readIds.add(notificationId);

    final stringIds = readIds.map((id) => id.toString()).toList();
    final userKey = _getUserKey(userEmail);
    await prefs.setStringList(userKey, stringIds);
  }

  /// Mark multiple notifications as read for a specific user
  Future<void> markMultipleAsRead(
    List<int> notificationIds,
    String userEmail,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = await getReadNotificationIds(userEmail);
    readIds.addAll(notificationIds);

    final stringIds = readIds.map((id) => id.toString()).toList();
    final userKey = _getUserKey(userEmail);
    await prefs.setStringList(userKey, stringIds);
  }

  /// Check if a notification is read for a specific user
  Future<bool> isRead(int notificationId, String userEmail) async {
    final readIds = await getReadNotificationIds(userEmail);
    return readIds.contains(notificationId);
  }

  /// Clear all read notifications for a specific user
  Future<void> clearAllReadNotifications(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(userEmail);
    await prefs.remove(userKey);
  }

  /// Get unread notification IDs from a list for a specific user
  Future<List<int>> getUnreadNotificationIds(
    List<int> allNotificationIds,
    String userEmail,
  ) async {
    final readIds = await getReadNotificationIds(userEmail);
    return allNotificationIds.where((id) => !readIds.contains(id)).toList();
  }

  /// Clear all read notifications for all users (for testing or reset)
  Future<void> clearAllUsersReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final readNotificationKeys = keys.where(
      (key) => key.startsWith(_readNotificationsKey),
    );

    for (final key in readNotificationKeys) {
      await prefs.remove(key);
    }
  }
}
