import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/notifications/models/notification_model.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';

class NotificationService {
  static const String baseUrl = 'https://udbconnect.com/api';

  Future<NotificationResponse> fetchNotifications({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final token = await const TokenStorage().readToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(
        '$baseUrl/notifications?page=$page&per_page=$perPage',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return NotificationResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await const TokenStorage().readToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$baseUrl/notifications/$notificationId/read');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final token = await const TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$baseUrl/notifications/unread-count');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return (jsonData['unread_count'] as num).toInt();
      } else {
        throw Exception('Failed to fetch unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      rethrow;
    }
  }
}
