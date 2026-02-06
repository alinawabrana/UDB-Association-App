import 'package:json_annotation/json_annotation.dart';
import '../../../../utils/constants/urls.dart';

part 'api_shop.g.dart';

@JsonSerializable()
class ApiShop {
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

  const ApiShop({
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

  factory ApiShop.fromJson(Map<String, dynamic> json) =>
      _$ApiShopFromJson(json);

  Map<String, dynamic> toJson() => _$ApiShopToJson(this);

  String? get fullImageUrl => ApiUrls.getShopImageUrl(image);
}
