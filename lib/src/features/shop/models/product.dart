import 'dart:convert';

/// Domain model representing a sellable product.
///
/// This model is designed to be API-friendly and future-proof:
/// - Uses value classes for `Money` and `Category` IDs
/// - Handles optional fields like `brand`, `variant`, and `tags`
/// - Provides JSON (de)serialization and copyWith for immutability
class Product {
  final String id;
  final String name;
  final String? description;
  final String? brand;
  final String? variant; // e.g. size or color option name
  final Money price;
  final String currencyCode; // ISO 4217, duplicated for API compatibility
  final String imageUrl;
  final String thumbnailUrl;
  final String feature; // short subtitle like "Cotton Blend"
  final String categoryId;
  final bool isFavorited;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.variant,
    required this.price,
    required this.currencyCode,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.feature,
    required this.categoryId,
    this.isFavorited = false,
    this.tags = const <String>[],
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? brand,
    String? variant,
    Money? price,
    String? currencyCode,
    String? imageUrl,
    String? thumbnailUrl,
    String? feature,
    String? categoryId,
    bool? isFavorited,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      variant: variant ?? this.variant,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      feature: feature ?? this.feature,
      categoryId: categoryId ?? this.categoryId,
      isFavorited: isFavorited ?? this.isFavorited,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'variant': variant,
      'price': price.toJson(),
      'currencyCode': currencyCode,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'feature': feature,
      'categoryId': categoryId,
      'isFavorited': isFavorited,
      'tags': tags,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      variant: json['variant'] as String?,
      price: json['price'] is Map<String, dynamic>
          ? Money.fromJson(json['price'] as Map<String, dynamic>)
          : Money(
              amountCents: (json['price_cents'] ?? 0) as int,
              currencyCode: json['currencyCode']?.toString() ?? 'USD',
            ),
      currencyCode: json['currencyCode']?.toString() ?? 'USD',
      imageUrl: json['imageUrl']?.toString() ?? '',
      thumbnailUrl:
          json['thumbnailUrl']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      feature: json['feature']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      isFavorited: (json['isFavorited'] ?? false) as bool,
      tags:
          (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
    );
  }

  static List<Product> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is List) {
      return decoded
          .map(
            (dynamic e) => Product.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
    }
    throw const FormatException('Expected a JSON array for products');
  }
}

/// Simple value object for currency amounts.
class Money {
  final int amountCents;
  final String currencyCode; // ISO 4217

  const Money({required this.amountCents, required this.currencyCode});

  double get amount => amountCents / 100.0;

  String format() {
    // Lightweight formatter; replace with intl if you need localization
    return '$currencyCode ${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amountCents': amountCents,
    'currencyCode': currencyCode,
  };

  factory Money.fromJson(Map<String, dynamic> json) => Money(
    amountCents: (json['amountCents'] ?? json['cents'] ?? 0) as int,
    currencyCode: json['currencyCode']?.toString() ?? 'USD',
  );
}

/// Category used for filtering chips.
class Category {
  final String id;
  final String name;
  final String? icon; // optional icon key or url

  const Category({required this.id, required this.name, this.icon});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'icon': icon,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    icon: json['icon'] as String?,
  );
}
