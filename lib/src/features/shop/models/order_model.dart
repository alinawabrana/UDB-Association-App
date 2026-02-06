class OrderUser {
  final int id;
  final String name;
  final String email;

  OrderUser({required this.id, required this.name, required this.email});

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class OrderModel {
  final int id;
  final int userId;
  final int shippingAddressId;
  final String totalAmount;
  final String subtotal;
  final String shippingFee;
  final String tax;
  final String status;
  final String paymentStatus;
  final String orderNumber;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final OrderUser? user; // Add user object

  OrderModel({
    required this.id,
    required this.userId,
    required this.shippingAddressId,
    required this.totalAmount,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.status,
    required this.paymentStatus,
    required this.orderNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.shippingAddress,
    this.user, // Add user to constructor
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      shippingAddressId: json['shipping_address_id'] ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      subtotal: json['subtotal']?.toString() ?? '0.00',
      shippingFee: json['shipping_fee']?.toString() ?? '0.00',
      tax: json['tax']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      orderNumber: json['order_number']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : ShippingAddress(
              id: 0,
              userId: 0,
              firstName: '',
              lastName: '',
              addressLine1: '',
              addressLine2: null,
              city: '',
              state: '',
              zipCode: '',
              country: '',
              phone: '',
              isDefault: false,
              createdAt: '',
              updatedAt: '',
            ),
      user: json['user'] != null ? OrderUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shipping_address_id': shippingAddressId,
      'total_amount': totalAmount,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'tax': tax,
      'status': status,
      'payment_status': paymentStatus,
      'order_number': orderNumber,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final String price;
  final String? discountedPrice;
  final String createdAt;
  final String updatedAt;
  final Product product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.discountedPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      discountedPrice: json['discounted_price']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discounted_price': discountedPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product.toJson(),
    };
  }
}

class Product {
  final int id;
  final String name;
  final String sku;
  final String? description;
  final String? image;
  final String price;
  final String? discountedPrice;
  final int stock;
  final String status;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.image,
    required this.price,
    this.discountedPrice,
    required this.stock,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      price: json['price']?.toString() ?? '0.00',
      discountedPrice: json['discounted_price']?.toString(),
      stock: json['stock'] ?? 0,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'image': image,
      'price': price,
      'discounted_price': discountedPrice,
      'stock': stock,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ShippingAddress {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  ShippingAddress({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phone,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'phone': phone,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class OrdersResponse {
  final int currentPage;
  final List<OrderModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<dynamic> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  OrdersResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((order) => OrderModel.fromJson(order))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: json['links'] ?? [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
