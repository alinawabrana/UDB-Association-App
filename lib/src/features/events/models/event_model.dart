class EventModel {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTimeString; // Time in HH:mm format or null
  final String? endTimeString; // Time in HH:mm format or null
  final String? location;
  final String image;
  final String type;
  final int? targetBranchId; // Nullable for global events
  final DateTime createdAt;
  final DateTime updatedAt;
  final String scope;
  final String category;
  final EventBranch? branch; // Nullable for global events
  final EventUser? user; // Contact user for the event
  final String? latitude; // Event location latitude
  final String? longitude; // Event location longitude

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.startTimeString,
    this.endTimeString,
    this.location,
    required this.image,
    required this.type,
    this.targetBranchId,
    required this.createdAt,
    required this.updatedAt,
    required this.scope,
    required this.category,
    this.branch,
    this.user,
    this.latitude,
    this.longitude,
  });

  EventModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? startTimeString,
    String? endTimeString,
    String? location,
    String? image,
    String? type,
    int? targetBranchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? scope,
    String? category,
    EventBranch? branch,
    EventUser? user,
    String? latitude,
    String? longitude,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTimeString: startTimeString ?? this.startTimeString,
      endTimeString: endTimeString ?? this.endTimeString,
      location: location ?? this.location,
      image: image ?? this.image,
      type: type ?? this.type,
      targetBranchId: targetBranchId ?? this.targetBranchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scope: scope ?? this.scope,
      category: category ?? this.category,
      branch: branch ?? this.branch,
      user: user ?? this.user,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.startTimeString == startTimeString &&
        other.endTimeString == endTimeString &&
        other.location == location &&
        other.image == image &&
        other.type == type &&
        other.targetBranchId == targetBranchId &&
        other.scope == scope &&
        other.category == category &&
        other.branch == branch &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      startDate,
      endDate,
      startTimeString,
      endTimeString,
      location,
      image,
      type,
      targetBranchId,
      scope,
      category,
      branch,
      user,
    );
  }

  // Factory method to create EventModel from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now(),
      startTimeString: json['start_time'] != null ? json['start_time'].toString() : null,
      endTimeString: json['end_time'] != null ? json['end_time'].toString() : null,
      location: json['location'] as String?,
      image: (json['image'] ?? '') as String,
      type: (json['category'] ?? 'event') as String,
      targetBranchId: json['target_branch_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      scope: (json['scope'] ?? 'global') as String,
      category: (json['category'] ?? 'event') as String,
      branch: json['branch'] != null
          ? EventBranch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? EventUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      latitude: json['latitude'] != null ? json['latitude'].toString() : null,
      longitude: json['longitude'] != null ? json['longitude'].toString() : null,
    );
  }

  // Convert EventModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'start_time': startTimeString,
      'end_time': endTimeString,
      'location': location,
      'image': image,
      'type': type,
      'target_branch_id': targetBranchId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'scope': scope,
      'category': category,
      'branch': branch?.toJson(),
      'user': user?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper getters for compatibility with existing UI
  String get subtitle => description;
  DateTime get startTimeDateTime => startDate;
  DateTime get endTimeDateTime => endDate;

  // Map category to EventType for filtering
  EventType get eventType {
    switch (category.toLowerCase()) {
      case 'meeting':
        return EventType.meeting;
      case 'event':
        return EventType.event;
      default:
        return EventType.task;
    }
  }

  // Default values for compatibility
  int get attendees => 0;
  EventPriority get priority => EventPriority.medium;
}

// EventBranch model for nested branch data
class EventBranch {
  final int id;
  final String name;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventBranch.fromJson(Map<String, dynamic> json) {
    return EventBranch(
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
    return other is EventBranch &&
        other.id == id &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, address);
  }
}

// EventUser model for event contact user
class EventUser {
  final int id;
  final String name;
  final String email;
  final String? role;
  final bool? isApproved;
  final EventUserProfile? profile;

  const EventUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.isApproved,
    this.profile,
  });

  factory EventUser.fromJson(Map<String, dynamic> json) {
    return EventUser(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: json['role'] as String?,
      isApproved: json['is_approved'] as bool?,
      profile: json['profile'] != null
          ? EventUserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_approved': isApproved,
      'profile': profile?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventUser &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email);
  }
}

// EventUserProfile for event user (simplified version)
class EventUserProfile {
  final String? profileImage;

  const EventUserProfile({
    this.profileImage,
  });

  factory EventUserProfile.fromJson(Map<String, dynamic> json) {
    return EventUserProfile(
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_image': profileImage,
    };
  }
}

enum EventType { meeting, event, task }

enum EventPriority { low, medium, high }

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.meeting:
        return 'Meetings';
      case EventType.event:
        return 'Events';
      case EventType.task:
        return 'Tasks';
    }
  }
}

extension EventPriorityExtension on EventPriority {
  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Low Priority';
      case EventPriority.medium:
        return 'Medium Priority';
      case EventPriority.high:
        return 'High Priority';
    }
  }
}
