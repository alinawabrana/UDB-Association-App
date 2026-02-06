// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiProduct _$ApiProductFromJson(Map<String, dynamic> json) => ApiProduct(
  id: (json['id'] as num).toInt(),
  shopId: (json['shop_id'] as num).toInt(),
  categoryId: (json['category_id'] as num).toInt(),
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String,
  price: json['price'] as String,
  discountedPrice: json['discounted_price'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  inStock: json['in_stock'] as bool?,
  lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
  status: json['status'] as bool?,
  sku: json['sku'] as String?,
  weight: json['weight'] as String?,
  dimensions: json['dimensions'] as String?,
  averageRating: json['average_rating'] as String,
  totalRatings: (json['total_ratings'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  category: json['category'] == null
      ? null
      : ApiCategory.fromJson(json['category'] as Map<String, dynamic>),
  shop: json['shop'] == null
      ? null
      : ApiShop.fromJson(json['shop'] as Map<String, dynamic>),
  primaryImage: const PrimaryImageConverter().fromJson(json['primary_image']),
);

Map<String, dynamic> _$ApiProductToJson(
  ApiProduct instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'category_id': instance.categoryId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'price': instance.price,
  'discounted_price': instance.discountedPrice,
  'quantity': instance.quantity,
  'in_stock': instance.inStock,
  'low_stock_threshold': instance.lowStockThreshold,
  'status': instance.status,
  'sku': instance.sku,
  'weight': instance.weight,
  'dimensions': instance.dimensions,
  'average_rating': instance.averageRating,
  'total_ratings': instance.totalRatings,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'category': instance.category,
  'shop': instance.shop,
  'primary_image': const PrimaryImageConverter().toJson(instance.primaryImage),
};
