// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetailResponse _$ProductDetailResponseFromJson(
  Map<String, dynamic> json,
) => ProductDetailResponse(
  product: ProductDetailData.fromJson(json['product'] as Map<String, dynamic>),
  avgRating: (json['avg_rating'] as num).toDouble(),
  userReview: json['user_review'],
  relatedProducts: (json['related_products'] as List<dynamic>)
      .map((e) => ApiProduct.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProductDetailResponseToJson(
  ProductDetailResponse instance,
) => <String, dynamic>{
  'product': instance.product,
  'avg_rating': instance.avgRating,
  'user_review': instance.userReview,
  'related_products': instance.relatedProducts,
};

ProductDetailData _$ProductDetailDataFromJson(Map<String, dynamic> json) =>
    ProductDetailData(
      id: (json['id'] as num).toInt(),
      shopId: (json['shop_id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: json['price'] as String,
      discountedPrice: json['discounted_price'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      inStock: json['in_stock'] as bool,
      lowStockThreshold: (json['low_stock_threshold'] as num).toInt(),
      status: json['status'] as bool,
      sku: json['sku'] as String?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as String?,
      averageRating: json['average_rating'] as String,
      totalRatings: (json['total_ratings'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: ProductCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      shop: ProductShop.fromJson(json['shop'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => ProductVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductDetailDataToJson(ProductDetailData instance) =>
    <String, dynamic>{
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
      'images': instance.images,
      'videos': instance.videos,
      'reviews': instance.reviews,
    };

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) =>
    ProductCategory(
      id: (json['id'] as num).toInt(),
      shopId: (json['shop_id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      status: json['status'] as bool,
      parentId: (json['parent_id'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'image': instance.image,
      'status': instance.status,
      'parent_id': instance.parentId,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProductShop _$ProductShopFromJson(Map<String, dynamic> json) => ProductShop(
  id: (json['id'] as num).toInt(),
  vendorProfileId: (json['vendor_profile_id'] as num).toInt(),
  subscriptionId: (json['subscription_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  tagline: json['tagline'] as String?,
  address: json['address'] as String?,
  image: json['image'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProductShopToJson(ProductShop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendor_profile_id': instance.vendorProfileId,
      'subscription_id': instance.subscriptionId,
      'name': instance.name,
      'description': instance.description,
      'tagline': instance.tagline,
      'address': instance.address,
      'image': instance.image,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  imageUrl: json['image_url'] as String,
  isPrimary: json['is_primary'] as bool,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'image_url': instance.imageUrl,
      'is_primary': instance.isPrimary,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProductVideo _$ProductVideoFromJson(Map<String, dynamic> json) => ProductVideo(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  videoUrl: json['video_url'] as String,
  isPrimary: json['is_primary'] as bool?,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProductVideoToJson(ProductVideo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'video_url': instance.videoUrl,
      'is_primary': instance.isPrimary,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProductReview _$ProductReviewFromJson(Map<String, dynamic> json) =>
    ProductReview(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductReviewToJson(ProductReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'user_id': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
