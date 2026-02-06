import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/news/models/comment_model.dart';
import 'package:udb_association/src/features/news/models/like_model.dart';
import 'package:udb_association/utils/network/retry.dart';

class LikeService {
  static const _baseUrl = 'https://udbconnect.com/api';

  Future<LikeStatus> fetchStatus({
    required String token,
    required ContentTargetType targetType,
    required int targetId,
  }) async {
    final uri = _buildUri(targetType, targetId);

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

    if (response.statusCode == 404) {
      return const LikeStatus(count: 0, isLiked: false);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _safeDecode(response.body);
      return _parseLikeStatus(decoded);
    }

    throw Exception('Failed to fetch likes: ${response.body}');
  }

  Future<void> like({
    required String token,
    required ContentTargetType targetType,
    required int targetId,
  }) async {
    final uri = _buildUri(targetType, targetId);
    final response = await retry(() async {
      final res = await http
          .post(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));
      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: res.statusCode,
        body: res.body,
      );
      return res;
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to like: ${response.body}');
    }
  }

  Future<void> unlike({
    required String token,
    required ContentTargetType targetType,
    required int targetId,
  }) async {
    final uri = _buildUri(targetType, targetId);
    final response = await retry(() async {
      final res = await http
          .delete(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));
      _logResponse(
        method: 'DELETE',
        uri: uri,
        statusCode: res.statusCode,
        body: res.body,
      );
      return res;
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to unlike: ${response.body}');
    }
  }

  Uri _buildUri(ContentTargetType targetType, int targetId) {
    final basePath = targetType == ContentTargetType.event ? 'events' : 'news';
    return Uri.parse('$_baseUrl/$basePath/$targetId/likes');
  }

  Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _safeDecode(String body) {
    if (body.isEmpty) {
      return const {};
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return const {};
    }
  }

  LikeStatus _parseLikeStatus(dynamic decoded) {
    final count = _extractCount(decoded);
    final liked = _extractIsLiked(decoded);
    return LikeStatus(
      count: count ?? 0,
      isLiked: liked ?? false,
      supportsLike: true,
    );
  }

  int? _extractCount(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded.length;
    }
    if (decoded is Map<String, dynamic>) {
      final keys = [
        'likes_count',
        'likesCount',
        'count',
        'total_likes',
        'likesTotal',
      ];
      for (final key in keys) {
        final value = decoded[key];
        final parsed = _toInt(value);
        if (parsed != null) {
          return parsed;
        }
      }
      final likes = decoded['likes'];
      final listCount = _extractCount(likes);
      if (listCount != null) {
        return listCount;
      }
      final data = decoded['data'];
      if (data != null && !identical(data, decoded)) {
        final nested = _extractCount(data);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  bool? _extractIsLiked(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final keys = [
        'liked',
        'is_liked',
        'isLiked',
        'user_has_liked',
        'has_liked',
      ];
      for (final key in keys) {
        final value = decoded[key];
        if (value is bool) {
          return value;
        }
        if (value is int) {
          return value != 0;
        }
        if (value is String) {
          if (value.toLowerCase() == 'true') return true;
          if (value.toLowerCase() == 'false') return false;
        }
      }
      final data = decoded['data'];
      if (data != null && !identical(data, decoded)) {
        final nested = _extractIsLiked(data);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    print('[Likes] $method $uri -> $statusCode\nResponse: $body');
  }
}
