class ReviewModel {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String? reviewText;
  final bool isApproved;
  final String createdAt;
  final String updatedAt;
  final ReviewUser? user;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.reviewText,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      reviewText: json['review_text']?.toString(),
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'review_text': reviewText,
      'is_approved': isApproved,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
    };
  }
}

class ReviewUser {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? provider;
  final String? providerId;
  final String role;
  final bool isApproved;
  final String createdAt;
  final String updatedAt;

  ReviewUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.provider,
    this.providerId,
    required this.role,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      provider: json['provider']?.toString(),
      providerId: json['provider_id']?.toString(),
      role: json['role']?.toString() ?? 'member',
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
      'role': role,
      'is_approved': isApproved,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductReviewsResponse {
  final bool status;
  final String message;
  final int productId;
  final List<ReviewModel> reviews;
  final ReviewPagination pagination;

  ProductReviewsResponse({
    required this.status,
    required this.message,
    required this.productId,
    required this.reviews,
    required this.pagination,
  });

  factory ProductReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ProductReviewsResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      productId: json['product_id'] ?? 0,
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((review) => ReviewModel.fromJson(review))
              .toList() ??
          [],
      pagination: ReviewPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'product_id': productId,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class ReviewPagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  ReviewPagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory ReviewPagination.fromJson(Map<String, dynamic> json) {
    return ReviewPagination(
      currentPage: json['current_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      lastPage: json['last_page'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total': total,
      'per_page': perPage,
      'last_page': lastPage,
    };
  }
}
