import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/news/models/comment_model.dart';
import 'package:udb_association/utils/network/retry.dart';

class CommentService {
  static const _baseUrl = 'https://udbconnect.com/api';

  Future<CommentPage> fetchComments({
    required String token,
    required ContentTargetType targetType,
    required int targetId,
    int page = 1,
  }) async {
    final baseUri = Uri.parse(
      targetType == ContentTargetType.event
          ? '$_baseUrl/events/$targetId/comments'
          : '$_baseUrl/news/$targetId/comments',
    );
    final uri = baseUri.replace(queryParameters: {'page': '$page'});

    print('💬 [COMMENT SERVICE] Fetching comments...');
    print('   Target Type: ${targetType.name}');
    print('   Target ID: $targetId');
    print('   Page: $page');
    print('   URL: $uri');
    print('   Timestamp: ${DateTime.now().toIso8601String()}');

    final response = await retry(() async {
      final res = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));
      _logResponse(
        method: 'GET',
        uri: uri,
        statusCode: res.statusCode,
        body: res.body,
      );
      return res;
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ [COMMENT SERVICE] Failed to fetch comments:');
      print('   Status Code: ${response.statusCode}');
      print('   Error: ${response.body}');
      throw Exception('Failed to fetch comments: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final pagination = _extractPagination(decoded);
    final List<dynamic> commentsJson = _extractCommentsList(decoded);
    final comments = commentsJson
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromJson)
        .toList();

    print('💬 [COMMENT SERVICE] Comments fetched successfully:');
    print('   Total Comments: ${pagination.total}');
    print('   Current Page: ${pagination.currentPage}');
    print('   Last Page: ${pagination.lastPage}');
    print('   Comments in this page: ${comments.length}');

    return CommentPage(
      comments: comments,
      total: pagination.total,
      currentPage: pagination.currentPage,
      lastPage: pagination.lastPage,
    );
  }

  Future<CommentModel> createComment({
    required String token,
    required ContentTargetType targetType,
    required int targetId,
    required String comment,
  }) async {
    final uri = Uri.parse(
      targetType == ContentTargetType.event
          ? '$_baseUrl/events/$targetId/comments'
          : '$_baseUrl/news/$targetId/comments',
    );

    final payload = jsonEncode({'body': comment, 'comment': comment});

    print('💬 [COMMENT SERVICE] Creating comment...');
    print('   Target Type: ${targetType.name}');
    print('   Target ID: $targetId');
    print('   Comment Length: ${comment.length}');
    print('   Comment Preview: ${comment.length > 50 ? comment.substring(0, 50) + "..." : comment}');
    print('   URL: $uri');
    print('   Payload: $payload');
    print('   Timestamp: ${DateTime.now().toIso8601String()}');

    final response = await retry(() async {
      final res = await http
          .post(uri, headers: _headers(token), body: payload)
          .timeout(const Duration(seconds: 20));
      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: res.statusCode,
        body: res.body,
      );
      return res;
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('💬 [COMMENT SERVICE] Comment created successfully!');
      print('   Status Code: ${response.statusCode}');
      
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic>? commentJson = _extractCreatedComment(decoded);
      if (commentJson != null) {
        print('💬 [COMMENT SERVICE] Comment parsed from response');
        return CommentModel.fromJson(commentJson);
      }
      // Fallback: construct from payload when API only sends message
      print('💬 [COMMENT SERVICE] Using fallback comment model');
      return CommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        content: comment,
        authorName: 'You',
        createdAt: DateTime.now(),
      );
    }

    print('❌ [COMMENT SERVICE] Failed to create comment:');
    print('   Status Code: ${response.statusCode}');
    print('   Error: ${response.body}');
    throw Exception('Failed to create comment: ${response.body}');
  }

  Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  List<dynamic> _extractCommentsList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List<dynamic>) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        final comments = data['comments'];
        if (comments is List<dynamic>) {
          return comments;
        }
        if (comments is Map<String, dynamic>) {
          final nested = comments['data'];
          if (nested is List<dynamic>) {
            return nested;
          }
        }
      }
      final comments = decoded['comments'];
      if (comments is List<dynamic>) {
        return comments;
      }
    }
    return const [];
  }

  _PaginationMeta _extractPagination(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final currentPage = _parseInt(decoded['current_page']) ?? 1;
      final lastPage = _parseInt(decoded['last_page']) ?? 1;
      final total = _parseInt(decoded['total']) ?? 0;
      return _PaginationMeta(
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
    }
    return const _PaginationMeta(currentPage: 1, lastPage: 1, total: 0);
  }

  Map<String, dynamic>? _extractCreatedComment(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      if (decoded['comment'] is Map<String, dynamic>) {
        return decoded['comment'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    print('[Comments] $method $uri -> $statusCode\nResponse: $body');
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class _PaginationMeta {
  const _PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int total;
}
