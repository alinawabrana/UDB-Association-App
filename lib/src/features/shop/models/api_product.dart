import 'package:json_annotation/json_annotation.dart';
import 'api_category.dart';
import 'api_shop.dart';
import '../../../../utils/constants/urls.dart';

part 'api_product.g.dart';

/// Converter for primary_image field that can be either String or Object
class PrimaryImageConverter implements JsonConverter<String?, dynamic> {
  const PrimaryImageConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) {
      return json['image_url'] as String?;
    }
    return null;
  }

  @override
  dynamic toJson(String? object) => object;
}

@JsonSerializable()
class ApiProduct {
  final int id;
  @JsonKey(name: 'shop_id')
  final int shopId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String name;
  final String slug;
  final String description;
  final String price;
  @JsonKey(name: 'discounted_price')
  final String? discountedPrice;
  final int quantity;
  @JsonKey(name: 'in_stock')
  final bool? inStock;
  @JsonKey(name: 'low_stock_threshold')
  final int? lowStockThreshold;
  final bool? status;
  final String? sku;
  final String? weight;
  final String? dimensions;
  @JsonKey(name: 'average_rating')
  final String averageRating;
  @JsonKey(name: 'total_ratings')
  final int totalRatings;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final ApiCategory? category;
  final ApiShop? shop;
  @JsonKey(name: 'primary_image')
  @PrimaryImageConverter()
  final String? primaryImage;

  const ApiProduct({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.quantity,
    this.inStock,
    this.lowStockThreshold,
    this.status,
    this.sku,
    this.weight,
    this.dimensions,
    required this.averageRating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.shop,
    this.primaryImage,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) =>
      _$ApiProductFromJson(json);

  Map<String, dynamic> toJson() => _$ApiProductToJson(this);

  String get imageUrl {
    if (primaryImage != null && primaryImage!.isNotEmpty) {
      return ApiUrls.getProductImageUrl(primaryImage);
    }
    if (category?.image != null && category!.image!.isNotEmpty) {
      return ApiUrls.getCategoryImageUrl(category!.image);
    }
    // For related products that don't have images, return a placeholder
    // In a real app, you might want to fetch the product detail to get the actual images
    return 'https://via.placeholder.com/300x300?text=No+Image+Available';
  }

  double get displayPrice =>
      double.tryParse(discountedPrice ?? '') ?? double.tryParse(price) ?? 0.0;
  double get originalPrice => double.tryParse(price) ?? 0.0;
  bool get hasDiscount =>
      discountedPrice != null &&
      discountedPrice!.isNotEmpty &&
      discountedPrice != price;

  // Safe getters for nullable fields
  bool get isInStock => inStock ?? true; // Default to true if null
  int get stockThreshold => lowStockThreshold ?? 0; // Default to 0 if null
  bool get isActive => status ?? true; // Default to true if null
}
