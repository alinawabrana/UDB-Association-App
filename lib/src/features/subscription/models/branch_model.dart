import 'dart:convert';

/// Model representing a branch from API
class Branch {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? image;
  final String? country;
  final String? province;
  final String? department;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Branch({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.image,
    this.country,
    this.province,
    this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to parse JSON from API
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      image: json['image'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      department: json['department'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'image': image,
      'country': country,
      'province': province,
      'department': department,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse list from JSON string
  static List<Branch> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => Branch.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }

  /// Parse list from JSON response body
  static List<Branch> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map((e) => Branch.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }
}
