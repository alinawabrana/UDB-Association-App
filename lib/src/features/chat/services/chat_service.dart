import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/chat/models/chat_models.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/utils/network/retry.dart';

class ChatService {
  static const String baseUrl = "https://udbconnect.com/api";
  final TokenStorage _tokenStorage = const TokenStorage();

  Future<String?> _getAuthToken() async {
    return await _tokenStorage.readToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// Fetch all chats for the current user
  Future<List<Chat>> getChats() async {
    final headers = await _getHeaders();
    print('[ChatService] GET /chats');

    final response = await retry(() async {
      return await http
          .get(Uri.parse("$baseUrl/chats"), headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] /chats OK ${response.statusCode}');
      final data = jsonDecode(response.body);
      final List<dynamic> rawList = (data is Map<String, dynamic>)
          ? (data['data'] as List<dynamic>? ??
                data['chats'] as List<dynamic>? ??
                [])
          : (data as List<dynamic>? ?? []);

      if (rawList.isEmpty && data is Map<String, dynamic>) {
        // Some APIs may return a single chat object for index; normalize to list
        if (data['chat'] != null && data['chat'] is Map<String, dynamic>) {
          return [Chat.fromJson(data['chat'] as Map<String, dynamic>)];
        }
      }

      return rawList.map((item) {
        // Support wrapped items like { chat: {...}, messages: {...} }
        if (item is Map<String, dynamic> && item['chat'] != null) {
          return Chat.fromJson(item['chat'] as Map<String, dynamic>);
        }
        return Chat.fromJson(item as Map<String, dynamic>);
      }).toList();
    } else {
      print(
        '[ChatService] /chats ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to fetch chats: ${response.body}");
    }
  }

  /// Fetch specific chat with messages
  Future<Chat> getChat(int chatId) async {
    final headers = await _getHeaders();
    print('[ChatService] GET /chats/$chatId');

    final response = await retry(() async {
      return await http
          .get(Uri.parse("$baseUrl/chats/$chatId"), headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] /chats/$chatId OK ${response.statusCode}');
      final data = jsonDecode(response.body);
      final chatJson = data is Map<String, dynamic> && data['chat'] != null
          ? data['chat']
          : data;
      return Chat.fromJson(chatJson as Map<String, dynamic>);
    } else {
      print(
        '[ChatService] /chats/$chatId ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to fetch chat: ${response.body}");
    }
  }

  /// Send a message to a chat
  Future<Message> sendMessageToChat({
    required int chatId,
    required String content,
  }) async {
    final headers = await _getHeaders();
    print(
      '[ChatService] POST /chats/$chatId/messages content length=${content.length}',
    );

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/chats/$chatId/messages"),
            headers: headers,
            body: jsonEncode({"content": content}),
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        '[ChatService] POST /chats/$chatId/messages OK ${response.statusCode}',
      );
      final data = jsonDecode(response.body);
      return Message.fromJson(data);
    } else {
      print(
        '[ChatService] POST /chats/$chatId/messages ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  /// Create a new chat
  Future<Chat> createChat(CreateChatRequest request) async {
    final headers = await _getHeaders();
    print('[ChatService] CREATE CHAT /chats body=${request.toJson()}');

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/chats"),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] CREATE CHAT OK ${response.statusCode}');
      final data = jsonDecode(response.body);
      return Chat.fromJson(data);
    } else {
      print(
        '[ChatService] CREATE CHAT ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to create chat: ${response.body}");
    }
  }

  /// Resolve a chat for a recipient (user or branch). Creates if not exists.
  Future<Chat> resolveChat({
    required String recipientType, // 'user' | 'branch'
    required int recipientId,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      "$baseUrl/chats/resolve?recipient_type=$recipientType&recipient_id=$recipientId",
    );
    print(
      '[ChatService] GET /chats/resolve recipient_type=$recipientType recipient_id=$recipientId',
    );

    final response = await retry(() async {
      return await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] /chats/resolve OK ${response.statusCode}');
      final data = jsonDecode(response.body);
      final chatJson = data is Map<String, dynamic> && data['chat'] != null
          ? data['chat']
          : data;
      return Chat.fromJson(chatJson as Map<String, dynamic>);
    } else {
      print(
        '[ChatService] /chats/resolve ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to resolve chat: ${response.body}");
    }
  }

  /// Search for users or branches to start a chat
  Future<List<ChatSearchResult>> searchRecipients(String query) async {
    final headers = await _getHeaders();
    print('[ChatService] GET /search/recipients?q=$query');

    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/search/recipients?q=$query"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] /search/recipients OK ${response.statusCode}');
      final data = jsonDecode(response.body);
      final List<dynamic> resultsJson = data['data'] ?? data;
      return resultsJson
          .map((json) => ChatSearchResult.fromJson(json))
          .toList();
    } else {
      print(
        '[ChatService] /search/recipients ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to search recipients: ${response.body}");
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(int chatId, List<int> messageIds) async {
    final headers = await _getHeaders();
    print('[ChatService] PATCH /chats/$chatId/mark-read ids=$messageIds');

    final response = await retry(() async {
      return await http
          .patch(
            Uri.parse("$baseUrl/chats/$chatId/mark-read"),
            headers: headers,
            body: jsonEncode({"message_ids": messageIds}),
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
        '[ChatService] mark-read ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to mark messages as read: ${response.body}");
    }
    print('[ChatService] mark-read OK');
  }

  /// Get chat messages with pagination
  Future<List<Message>> getChatMessages(
    int chatId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final headers = await _getHeaders();
    print('[ChatService] GET /chats/$chatId?page=$page&per_page=$perPage');

    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/chats/$chatId?page=$page&per_page=$perPage"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ChatService] /chats/$chatId OK ${response.statusCode}');
      final data = jsonDecode(response.body);

      // Backend returns: { chat: {...}, messages: { data: [...], pagination: {...} } }
      if (data['messages'] != null && data['messages']['data'] != null) {
        final List<dynamic> messagesJson = data['messages']['data'];
        print('[ChatService] Found ${messagesJson.length} messages');
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      }

      // Fallback: empty messages
      print('[ChatService] No messages found in response');
      return [];
    } else {
      print(
        '[ChatService] /chats/$chatId ERROR ${response.statusCode}: ${response.body}',
      );
      throw Exception("Failed to fetch messages: ${response.body}");
    }
  }
}
