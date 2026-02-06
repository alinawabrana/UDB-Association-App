import '../../auth/models/user_model.dart';
import 'subscription_plan.dart';

/// Model representing a user subscription request from API
class UserSubscriptionRequest {
  final int id;
  final int userId;
  final int subscriptionId;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final SubscriptionPlan? subscription;

  const UserSubscriptionRequest({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.subscription,
  });

  /// Factory constructor to parse JSON from API
  factory UserSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      subscriptionId: json['subscription_id'] as int,
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      subscription: json['subscription'] != null
          ? SubscriptionPlan.fromJson(json['subscription'])
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'subscription': subscription?.toJson(),
    };
  }

  /// Parse list from JSON response body
  static List<UserSubscriptionRequest> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map(
            (e) => UserSubscriptionRequest.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }

  /// Check if subscription request is approved
  bool get isApproved {
    return status.toLowerCase() == 'approved';
  }

  /// Check if subscription request is pending
  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  /// Check if subscription request is expired (for approved subscriptions)
  bool get isExpired {
    if (!isApproved || subscription == null) return false;

    // Calculate expiry date based on subscription duration
    final now = DateTime.now();
    final createdDate = createdAt;

    // Parse duration from subscription
    final duration = subscription!.duration.toLowerCase();
    DateTime expiryDate;

    if (duration.contains('weekly')) {
      expiryDate = createdDate.add(const Duration(days: 7));
    } else if (duration.contains('monthly')) {
      expiryDate = createdDate.add(const Duration(days: 30));
    } else if (duration.contains('yearly') || duration.contains('annual')) {
      expiryDate = createdDate.add(const Duration(days: 365));
    } else {
      // Default to monthly if unknown
      expiryDate = createdDate.add(const Duration(days: 30));
    }

    return now.isAfter(expiryDate);
  }

  /// Check if subscription is active (approved and not expired)
  bool get isActive {
    return isApproved && !isExpired;
  }
}

/// Model for user subscription requests API response
class UserSubscriptionRequestResponse {
  final bool status;
  final String message;
  final List<UserSubscriptionRequest> data;

  const UserSubscriptionRequestResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserSubscriptionRequestResponse.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionRequestResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: UserSubscriptionRequest.listFromJson(json),
    );
  }
}
