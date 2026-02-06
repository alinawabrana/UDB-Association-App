import 'subscription_plan.dart';
import '../../auth/models/user_model.dart';

/// Model representing a subscription booking from API
class SubscriptionBooking {
  final int id;
  final int userId;
  final int subscriptionId;
  final int? branchId;
  final String paymentStatus;
  final DateTime bookingDate;
  final DateTime expiryDate;
  final String amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final SubscriptionPlan? subscription;

  const SubscriptionBooking({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    this.branchId,
    required this.paymentStatus,
    required this.bookingDate,
    required this.expiryDate,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.subscription,
  });

  /// Factory constructor to parse JSON from API
  factory SubscriptionBooking.fromJson(Map<String, dynamic> json) {
    return SubscriptionBooking(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      subscriptionId: json['subscription_id'] as int,
      branchId: json['branch_id'] as int?,
      paymentStatus: json['payment_status']?.toString() ?? '',
      bookingDate: DateTime.parse(
        json['booking_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      expiryDate: DateTime.parse(
        json['expiry_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      amount: json['amount']?.toString() ?? '0.00',
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
      'branch_id': branchId,
      'payment_status': paymentStatus,
      'booking_date': bookingDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'subscription': subscription?.toJson(),
    };
  }

  /// Parse list from JSON response body
  static List<SubscriptionBooking> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map(
            (e) => SubscriptionBooking.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }

  /// Check if subscription is active (not expired)
  bool get isActive {
    return expiryDate.isAfter(DateTime.now()) &&
        paymentStatus.toLowerCase() == 'paid';
  }

  /// Check if subscription is active for user role (paid status only, no expiry check)
  bool get isActiveForUser {
    return paymentStatus.toLowerCase() == 'paid';
  }

  /// Check if subscription is approved for user role (paid + not expired + user approved)
  bool get isApprovedForUser {
    return paymentStatus.toLowerCase() == 'paid' &&
        expiryDate.isAfter(DateTime.now()) &&
        (user?.isApproved ?? false);
  }

  /// Get amount as double
  double get amountValue => double.tryParse(amount) ?? 0.0;

  /// Get days remaining until expiry
  int get daysRemaining {
    final difference = expiryDate.difference(DateTime.now());
    return difference.inDays;
  }
}

/// Model for pagination data
class SubscriptionBookingResponse {
  final List<SubscriptionBooking> data;
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  const SubscriptionBookingResponse({
    required this.data,
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory SubscriptionBookingResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionBookingResponse(
      data: SubscriptionBooking.listFromJson(json),
      currentPage: json['pagination']?['current_page'] ?? 1,
      total: json['pagination']?['total'] ?? 0,
      perPage: json['pagination']?['per_page'] ?? 10,
      lastPage: json['pagination']?['last_page'] ?? 1,
    );
  }
}
