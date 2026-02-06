class NewsModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final String scope;
  final int? targetBranchId;
  final int userId;
  final String status;
  final String image;
  final DateTime publishDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NewsBranch? branch;
  final NewsUser user;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.scope,
    this.targetBranchId,
    required this.userId,
    required this.status,
    required this.image,
    required this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    this.branch,
    required this.user,
  });

  NewsModel copyWith({
    int? id,
    String? title,
    String? content,
    String? type,
    String? scope,
    int? targetBranchId,
    int? userId,
    String? status,
    String? image,
    DateTime? publishDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    NewsBranch? branch,
    NewsUser? user,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      targetBranchId: targetBranchId ?? this.targetBranchId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      image: image ?? this.image,
      publishDate: publishDate ?? this.publishDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branch: branch ?? this.branch,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.type == type &&
        other.scope == scope &&
        other.targetBranchId == targetBranchId &&
        other.userId == userId &&
        other.status == status &&
        other.image == image &&
        other.publishDate == publishDate &&
        other.branch == branch &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      type,
      scope,
      targetBranchId,
      userId,
      status,
      image,
      publishDate,
      branch,
      user,
    );
  }

  // Factory method to create NewsModel from JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      type: (json['type'] ?? 'news') as String,
      scope: (json['scope'] ?? 'global') as String,
      targetBranchId: json['target_branch_id'] as int?,
      userId: json['user_id'] as int,
      status: (json['status'] ?? 'published') as String,
      image: (json['image'] ?? '') as String,
      publishDate: json['publish_date'] != null
          ? DateTime.parse(json['publish_date'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      branch: json['branch'] != null
          ? NewsBranch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? NewsUser.fromJson(json['user'] as Map<String, dynamic>)
          : NewsUser(
              id: 0,
              name: '',
              email: '',
              role: 'user',
              isApproved: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }

  // Convert NewsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'scope': scope,
      'target_branch_id': targetBranchId,
      'user_id': userId,
      'status': status,
      'image': image,
      'publish_date': publishDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'branch': branch?.toJson(),
      'user': user.toJson(),
    };
  }

  // Helper getters for compatibility with existing UI
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
}

// NewsBranch model for nested branch data
class NewsBranch {
  final int id;
  final String name;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsBranch.fromJson(Map<String, dynamic> json) {
    return NewsBranch(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsBranch &&
        other.id == id &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, address);
  }
}

// NewsUser model for nested user data
class NewsUser {
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

  const NewsUser({
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

  factory NewsUser.fromJson(Map<String, dynamic> json) {
    return NewsUser(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      role: (json['role'] ?? 'user') as String,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
      'role': role,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsUser &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.isApproved == isApproved;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, isApproved);
  }
}

enum NewsType { news, announcement, update }

extension NewsTypeExtension on NewsType {
  String get displayName {
    switch (this) {
      case NewsType.news:
        return 'News';
      case NewsType.announcement:
        return 'Announcements';
      case NewsType.update:
        return 'Updates';
    }
  }
}
