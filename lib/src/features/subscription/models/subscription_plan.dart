import 'dart:convert';

/// Model representing a subscription plan from API
class SubscriptionPlan {
  final int id;
  final String title;
  final String quote; // maps to benefitsSubtitle
  final List<String> benefits;
  final String type; // maps to planName: "premium", "basic", "enterprise"
  final String plansFor; // "member" or "vendor"
  final String duration; // "weekly", "monthly", "annual"
  final String price;
  final String? discountType;
  final String? discountValue;
  final String? discountedPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.quote,
    required this.benefits,
    required this.type,
    required this.plansFor,
    required this.duration,
    required this.price,
    this.discountType,
    this.discountValue,
    this.discountedPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to parse JSON from API
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      quote: json['quote']?.toString() ?? '',
      benefits:
          (json['benefits'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      type: json['type']?.toString() ?? '',
      plansFor: json['plans_for']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      discountType: json['discount_type'] as String?,
      discountValue: json['discount_value'] as String?,
      discountedPrice: json['discounted_price'] as String?,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'quote': quote,
      'benefits': benefits,
      'type': type,
      'plans_for': plansFor,
      'duration': duration,
      'price': price,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discounted_price': discountedPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse list from JSON string
  static List<SubscriptionPlan> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map(
            (e) =>
                SubscriptionPlan.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }

  /// Parse list from JSON response body
  static List<SubscriptionPlan> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map(
            (e) =>
                SubscriptionPlan.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }

  /// Get display price (use discounted if available)
  String get displayPrice => discountedPrice ?? price;

  /// Get price as double
  double get priceValue => double.tryParse(price) ?? 0.0;

  /// Get discounted price as double
  double? get discountedPriceValue =>
      discountedPrice != null ? double.tryParse(discountedPrice!) : null;
}
