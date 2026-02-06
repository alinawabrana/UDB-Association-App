import 'package:json_annotation/json_annotation.dart';
import 'api_product.dart';
import '../../../../utils/constants/urls.dart';

part 'product_detail_response.g.dart';

@JsonSerializable()
class ProductDetailResponse {
  final ProductDetailData product;
  @JsonKey(name: 'avg_rating')
  final double avgRating;
  @JsonKey(name: 'user_review')
  final dynamic userReview; // Can be null or a review object
  @JsonKey(name: 'related_products')
  final List<ApiProduct> relatedProducts;

  const ProductDetailResponse({
    required this.product,
    required this.avgRating,
    required this.userReview,
    required this.relatedProducts,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductDetailResponseFromJson(json);
    } catch (e) {
      print('Error in ProductDetailResponse.fromJson: $e');
      print('JSON content: $json');

      // More robust fallback parsing with null checks
      return ProductDetailResponse(
        product: json['product'] != null
            ? ProductDetailData.fromJson(
                json['product'] as Map<String, dynamic>,
              )
            : throw Exception('Product data is null'),
        avgRating: json['avg_rating'] != null
            ? (json['avg_rating'] as num).toDouble()
            : 0.0,
        userReview: json['user_review'],
        relatedProducts: json['related_products'] != null
            ? (json['related_products'] as List<dynamic>)
                  .map(
                    (e) => e != null
                        ? ApiProduct.fromJson(e as Map<String, dynamic>)
                        : null,
                  )
                  .where((e) => e != null)
                  .cast<ApiProduct>()
                  .toList()
            : <ApiProduct>[],
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductDetailResponseToJson(this);
}

@JsonSerializable()
class ProductDetailData {
  final int id;
  @JsonKey(name: 'shop_id')
  final int shopId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final String price;
  @JsonKey(name: 'discounted_price')
  final String? discountedPrice;
  final int quantity;
  @JsonKey(name: 'in_stock')
  final bool inStock;
  @JsonKey(name: 'low_stock_threshold')
  final int lowStockThreshold;
  final bool status;
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
  final ProductCategory category;
  final ProductShop shop;
  final List<ProductImage> images;
  final List<ProductVideo> videos;
  final List<ProductReview> reviews;

  const ProductDetailData({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.discountedPrice,
    required this.quantity,
    required this.inStock,
    required this.lowStockThreshold,
    required this.status,
    this.sku,
    this.weight,
    this.dimensions,
    required this.averageRating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.shop,
    required this.images,
    required this.videos,
    required this.reviews,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductDetailDataFromJson(json);
    } catch (e) {
      print('Error parsing ProductDetailData: $e');
      print('JSON keys: ${json.keys.toList()}');
      print('Category: ${json['category']}');
      print('Shop: ${json['shop']}');
      print('Images: ${json['images']}');
      print('Videos: ${json['videos']}');
      print('Reviews: ${json['reviews']}');

      // Fallback manual parsing with comprehensive null safety
      return ProductDetailData(
        id: json['id'] as int,
        shopId: json['shop_id'] as int,
        categoryId: json['category_id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        price: json['price'] as String,
        discountedPrice: json['discounted_price'] as String?,
        quantity: json['quantity'] as int,
        inStock: json['in_stock'] as bool,
        lowStockThreshold: json['low_stock_threshold'] as int,
        status: json['status'] as bool,
        sku: json['sku'] as String?,
        weight: json['weight'] as String?,
        dimensions: json['dimensions'] as String?,
        averageRating: json['average_rating'] as String,
        totalRatings: json['total_ratings'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        category: json['category'] != null
            ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
            : throw Exception('Category data is null'),
        shop: json['shop'] != null
            ? ProductShop.fromJson(json['shop'] as Map<String, dynamic>)
            : throw Exception('Shop data is null'),
        images: json['images'] != null
            ? (json['images'] as List<dynamic>)
                  .map(
                    (e) => e != null
                        ? ProductImage.fromJson(e as Map<String, dynamic>)
                        : null,
                  )
                  .where((e) => e != null)
                  .cast<ProductImage>()
                  .toList()
            : <ProductImage>[],
        videos: json['videos'] != null
            ? (json['videos'] as List<dynamic>)
                  .map(
                    (e) => e != null
                        ? ProductVideo.fromJson(e as Map<String, dynamic>)
                        : null,
                  )
                  .where((e) => e != null)
                  .cast<ProductVideo>()
                  .toList()
            : <ProductVideo>[],
        reviews: json['reviews'] != null
            ? (json['reviews'] as List<dynamic>)
                  .map(
                    (e) => e != null
                        ? ProductReview.fromJson(e as Map<String, dynamic>)
                        : null,
                  )
                  .where((e) => e != null)
                  .cast<ProductReview>()
                  .toList()
            : <ProductReview>[],
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductDetailDataToJson(this);

  double get displayPrice =>
      double.tryParse(discountedPrice ?? '') ?? double.tryParse(price) ?? 0.0;
  double get originalPrice => double.tryParse(price) ?? 0.0;
  bool get hasDiscount =>
      discountedPrice != null &&
      discountedPrice!.isNotEmpty &&
      discountedPrice != price;
}

@JsonSerializable()
class ProductCategory {
  final int id;
  @JsonKey(name: 'shop_id')
  final int shopId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final bool status;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProductCategory({
    required this.id,
    required this.shopId,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.status,
    this.parentId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductCategoryFromJson(json);
    } catch (e) {
      print('Error parsing ProductCategory: $e');
      // Fallback manual parsing
      return ProductCategory(
        id: json['id'] as int,
        shopId: json['shop_id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        image: json['image'] as String?,
        status: json['status'] as bool,
        parentId: json['parent_id'] as int?,
        sortOrder: json['sort_order'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

  String? get imageUrl {
    return ApiUrls.getCategoryImageUrl(image);
  }
}

@JsonSerializable()
class ProductShop {
  final int id;
  @JsonKey(name: 'vendor_profile_id')
  final int vendorProfileId;
  @JsonKey(name: 'subscription_id')
  final int subscriptionId;
  final String name;
  final String? description;
  final String? tagline;
  final String? address;
  final String? image;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProductShop({
    required this.id,
    required this.vendorProfileId,
    required this.subscriptionId,
    required this.name,
    this.description,
    this.tagline,
    this.address,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductShop.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductShopFromJson(json);
    } catch (e) {
      print('Error parsing ProductShop: $e');
      // Fallback manual parsing
      return ProductShop(
        id: json['id'] as int,
        vendorProfileId: json['vendor_profile_id'] as int,
        subscriptionId: json['subscription_id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        tagline: json['tagline'] as String?,
        address: json['address'] as String?,
        image: json['image'] as String?,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductShopToJson(this);

  String? get imageUrl {
    return ApiUrls.getShopImageUrl(image);
  }
}

@JsonSerializable()
class ProductImage {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isPrimary,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductImageFromJson(json);
    } catch (e) {
      print('Error parsing ProductImage: $e');
      return ProductImage(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        imageUrl: json['image_url'] as String,
        isPrimary: json['is_primary'] as bool,
        sortOrder: json['sort_order'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductImageToJson(this);

  String get fullImageUrl => ApiUrls.getProductImageUrl(imageUrl);
}

@JsonSerializable()
class ProductVideo {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'video_url')
  final String videoUrl;
  @JsonKey(name: 'is_primary')
  final bool? isPrimary;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProductVideo({
    required this.id,
    required this.productId,
    required this.videoUrl,
    this.isPrimary,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductVideoFromJson(json);
    } catch (e) {
      print('Error parsing ProductVideo: $e');
      return ProductVideo(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        videoUrl: json['video_url'] as String,
        isPrimary: json['is_primary'] as bool?,
        sortOrder: json['sort_order'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductVideoToJson(this);

  String get fullVideoUrl => ApiUrls.getMediaUrl(videoUrl);
}

@JsonSerializable()
class ProductReview {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'user_id')
  final int userId;
  final int rating;
  final String? comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductReviewFromJson(json);
    } catch (e) {
      print('Error parsing ProductReview: $e');
      return ProductReview(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        userId: json['user_id'] as int,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProductReviewToJson(this);
}
