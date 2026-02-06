import 'package:intl/intl.dart';

enum ContentTargetType { news, event }

class CommentRequest {
  const CommentRequest({
    required this.targetType,
    required this.targetId,
    this.page = 1,
  });

  final ContentTargetType targetType;
  final int targetId;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentRequest &&
        other.targetType == targetType &&
        other.targetId == targetId &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(targetType, targetId, page);
}

class CommentModel {
  const CommentModel({
    required this.id,
    required this.content,
    required this.authorName,
    this.createdAt,
  });

  final int id;
  final String content;
  final String authorName;
  final DateTime? createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = _extractUser(json);
    return CommentModel(
      id: _parseInt(json['id']),
      content: _extractContent(json),
      authorName: _extractUserName(user, json),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  String get formattedDate {
    if (createdAt == null) {
      return '';
    }
    return DateFormat('MMM d, yyyy • h:mm a').format(createdAt!);
  }

  static Map<String, dynamic>? _extractUser(Map<String, dynamic> json) {
    final rawUser = json['user'] ?? json['author'] ?? json['created_by'];
    if (rawUser is Map<String, dynamic>) {
      return rawUser;
    }
    return null;
  }

  static String _extractUserName(
    Map<String, dynamic>? user,
    Map<String, dynamic> json,
  ) {
    if (user != null) {
      // Try to construct name from first_name and surname (new API structure)
      final firstName = user['first_name']?.toString();
      final surname = user['surname']?.toString();
      
      if (firstName != null && firstName.isNotEmpty && surname != null && surname.isNotEmpty) {
        return '$firstName $surname';
      } else if (firstName != null && firstName.isNotEmpty) {
        return firstName;
      } else if (surname != null && surname.isNotEmpty) {
        return surname;
      }
      
      // Fallback to old API structure fields
      return user['name']?.toString() ??
          user['full_name']?.toString() ??
          user['username']?.toString() ??
          'Unknown';
    }
    return json['user_name']?.toString() ??
        json['author_name']?.toString() ??
        'Unknown';
  }

  static String _extractContent(Map<String, dynamic> json) {
    return json['comment']?.toString() ??
        json['content']?.toString() ??
        json['body']?.toString() ??
        '';
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }
}

class CommentPage {
  const CommentPage({
    required this.comments,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  final List<CommentModel> comments;
  final int total;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
