/// Converter for primary_image field that can be either String or Object
class PrimaryImageConverter {
  const PrimaryImageConverter();

  static String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) {
      return json['image_url'] as String?;
    }
    return null;
  }

  static dynamic toJson(String? object) => object;
}

class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final String createdAt;
  final String updatedAt;
  final CartProduct product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      cartId: json['cart_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      product: CartProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product.toJson(),
    };
  }
}

class CartProduct {
  final int id;
  final int shopId;
  final int categoryId;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String? discountedPrice;
  final int quantity;
  final bool inStock;
  final int lowStockThreshold;
  final bool status;
  final String? sku;
  final String? weight;
  final String? dimensions;
  final String averageRating;
  final int totalRatings;
  final String createdAt;
  final String updatedAt;
  final String? primaryImage;

  CartProduct({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
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
    this.primaryImage,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int,
      shopId: json['shop_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
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
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      primaryImage: PrimaryImageConverter.fromJson(json['primary_image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'discounted_price': discountedPrice,
      'quantity': quantity,
      'in_stock': inStock,
      'low_stock_threshold': lowStockThreshold,
      'status': status,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'primary_image': primaryImage,
    };
  }
}
