int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class ChatParticipant {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String? role;
  final DateTime? joinedAt;
  final int? pivotUserId; // from pivot.user_id if provided
  final int? pivotChatId; // from pivot.chat_id if provided

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.role,
    this.joinedAt,
    this.pivotUserId,
    this.pivotChatId,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>?;
    return ChatParticipant(
      id: _asInt(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      pivotUserId: pivot != null ? _asInt(pivot['user_id']) : null,
      pivotChatId: pivot != null ? _asInt(pivot['chat_id']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
      'pivot': {
        if (pivotUserId != null) 'user_id': pivotUserId,
        if (pivotChatId != null) 'chat_id': pivotChatId,
      },
    };
  }
}

class Message {
  final int id;
  final String content;
  final int userId;
  final String userName;
  final String? userImage;
  final int chatId;
  final String? messageType; // 'text', 'file', 'image'
  final String? fileName;
  final String? fileSize;
  final String? fileUrl;
  final bool isRead;
  final bool isFromCurrentUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Message({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.chatId,
    this.messageType,
    this.fileName,
    this.fileSize,
    this.fileUrl,
    this.isRead = false,
    this.isFromCurrentUser = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle nested user object structure from backend
    final user = json['user'] as Map<String, dynamic>?;

    return Message(
      id: _asInt(json['id']),
      content: json['content'] as String? ?? '',
      userId: json['user_id'] != null
          ? _asInt(json['user_id'])
          : (user != null ? _asInt(user['id']) : 0),
      userName: user?['name'] as String? ?? 'Unknown',
      userImage: user?['profile_image'] as String?,
      chatId: _asInt(json['chat_id']),
      messageType: 'text', // Backend doesn't send message_type, default to text
      fileName: null,
      fileSize: null,
      fileUrl: null,
      isRead: json['is_read'] as bool? ?? false,
      isFromCurrentUser: false, // Will be set by Flutter based on current user
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'chat_id': chatId,
      'message_type': messageType,
      'file_name': fileName,
      'file_size': fileSize,
      'file_url': fileUrl,
      'is_read': isRead,
      'is_from_current_user': isFromCurrentUser,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Chat {
  final int id;
  final String? name;
  final String? type; // 'private' or 'group'
  final String? image;
  final List<ChatParticipant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Chat({
    required this.id,
    this.name,
    this.type,
    this.image,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Allow alternative keys often used by APIs
    final participantsJson =
        (json['participants'] ?? json['users']) as List<dynamic>?;
    return Chat(
      id: _asInt(json['id']),
      name: json['name'] as String?,
      type: json['type'] as String?,
      image: json['image'] as String?,
      participants:
          participantsJson
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] == null
          ? 0
          : _asInt(json['unread_count']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'image': image,
      'participants': participants.map((e) => e.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class SendMessageRequest {
  final String content;
  final int recipientId;
  final String recipientType;

  const SendMessageRequest({
    required this.content,
    required this.recipientId,
    required this.recipientType,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'recipient_id': recipientId,
      'recipient_type': recipientType,
    };
  }
}

class CreateChatRequest {
  final int recipientId;
  final String? name;
  final String? type;

  const CreateChatRequest({required this.recipientId, this.name, this.type});

  Map<String, dynamic> toJson() {
    return {'recipient_id': recipientId, 'name': name, 'type': type};
  }
}

class ChatSearchResult {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String? role;
  final String? type; // 'user' or 'branch'
  final int? branchId;

  const ChatSearchResult({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.role,
    this.type,
    this.branchId,
  });

  factory ChatSearchResult.fromJson(Map<String, dynamic> json) {
    return ChatSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      type: json['type'] as String?,
      branchId: json['branch_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'type': type,
      'branch_id': branchId,
    };
  }
}
