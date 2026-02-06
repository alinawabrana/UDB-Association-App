import 'dart:convert';
import '../../../../utils/constants/urls.dart';

class Shop {
  final int id;
  final int vendorProfileId;
  final int subscriptionId;
  final String name;
  final String description;
  final String tagline;
  final String address;
  final String? image;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  // Computed property that uses the new base URL
  String? get fullImageUrl => ApiUrls.getShopImageUrl(image ?? imageUrl);

  final VendorProfile vendorProfile;

  const Shop({
    required this.id,
    required this.vendorProfileId,
    required this.subscriptionId,
    required this.name,
    required this.description,
    required this.tagline,
    required this.address,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    required this.vendorProfile,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: (json['id'] as num).toInt(),
      vendorProfileId: (json['vendor_profile_id'] as num).toInt(),
      subscriptionId: (json['subscription_id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      image: json['image'] as String?,
      status: (json['status'] as String?) ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      imageUrl: json['image_url'] as String?,
      vendorProfile: VendorProfile.fromJson(
        (json['vendor_profile'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_profile_id': vendorProfileId,
      'subscription_id': subscriptionId,
      'name': name,
      'description': description,
      'tagline': tagline,
      'address': address,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
      'vendor_profile': vendorProfile.toJson(),
    };
  }

  static List<Shop> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is List) {
      return decoded
          .map((dynamic e) => Shop.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw const FormatException('Expected a JSON array for shops');
  }

  // Sample data for development
  static List<Shop> getSampleShops() {
    return [
      Shop(
        id: 4,
        vendorProfileId: 8,
        subscriptionId: 1,
        name: "fffgffgfg",
        description: "fgfgffgfgf",
        tagline: "bbbvbvbv",
        address: "dsfsdfdsf",
        image: "shops/zLY1FqP8rsTLH5Y88aQdOHnUWixT5lGdstyKXg1r.png",
        status: "active",
        createdAt: DateTime.parse('2025-10-02T21:37:42.000000Z'),
        updatedAt: DateTime.parse('2025-10-02T21:52:33.000000Z'),
        imageUrl:
            "https://udbconnect.com/storage/app/public/shops/zLY1FqP8rsTLH5Y88aQdOHnUWixT5lGdstyKXg1r.png",
        vendorProfile: VendorProfile(
          id: 8,
          userId: 26,
          phone: "2323232323",
          address: "dsfsdfdsf",
          countryCode: "+1",
          businessName: "fffgffgfg",
          shopDetails: "fgfgffgfgf",
          createdAt: DateTime.parse('2025-10-02T21:37:42.000000Z'),
          updatedAt: DateTime.parse('2025-10-02T21:37:42.000000Z'),
          profileImage: null,
          profileImageUrl: null,
          user: User(
            id: 26,
            name: "hshdgshdg",
            email: "bcd@gmail.com",
            emailVerifiedAt: null,
            provider: null,
            providerId: null,
            role: "vendor",
            isApproved: true,
            createdAt: DateTime.parse('2025-10-02T21:37:15.000000Z'),
            updatedAt: DateTime.parse('2025-10-02T21:38:08.000000Z'),
          ),
        ),
      ),
      Shop(
        id: 5,
        vendorProfileId: 9,
        subscriptionId: 1,
        name: "My Business",
        description: "E-commerce store details",
        tagline: "Best Deals",
        address: "123 Main St",
        image: null,
        status: "active",
        createdAt: DateTime.parse('2025-10-02T22:28:06.000000Z'),
        updatedAt: DateTime.parse('2025-10-02T22:29:05.000000Z'),
        imageUrl: null,
        vendorProfile: VendorProfile(
          id: 9,
          userId: 27,
          phone: "1234567890",
          address: "123 Main St",
          countryCode: "+1",
          businessName: "My Business",
          shopDetails: "E-commerce store details",
          createdAt: DateTime.parse('2025-10-02T22:28:06.000000Z'),
          updatedAt: DateTime.parse('2025-10-02T22:28:06.000000Z'),
          profileImage: null,
          profileImageUrl: null,
          user: User(
            id: 27,
            name: "zainab",
            email: "zainab@gmail.com",
            emailVerifiedAt: null,
            provider: null,
            providerId: null,
            role: "vendor",
            isApproved: true,
            createdAt: DateTime.parse('2025-10-02T22:02:57.000000Z'),
            updatedAt: DateTime.parse('2025-10-02T22:29:05.000000Z'),
          ),
        ),
      ),
    ];
  }
}

class VendorProfile {
  final int id;
  final int userId;
  final String phone;
  final String address;
  final String countryCode;
  final String businessName;
  final String shopDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;
  final String? profileImageUrl;
  final User user;

  const VendorProfile({
    required this.id,
    required this.userId,
    required this.phone,
    required this.address,
    required this.countryCode,
    required this.businessName,
    required this.shopDetails,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
    this.profileImageUrl,
    required this.user,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      countryCode: (json['country_code'] as String?) ?? '',
      businessName: (json['business_name'] as String?) ?? '',
      shopDetails: (json['shop_details'] as String?) ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      profileImage: json['profile_image'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      user: User.fromJson((json['user'] as Map).cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone': phone,
      'address': address,
      'country_code': countryCode,
      'business_name': businessName,
      'shop_details': shopDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String? provider;
  final String? providerId;
  final String role;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      role: json['role'] as String,
      isApproved: json['is_approved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'provider': provider,
      'provider_id': providerId,
      'role': role,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
