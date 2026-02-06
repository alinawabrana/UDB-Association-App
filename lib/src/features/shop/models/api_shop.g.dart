// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiShop _$ApiShopFromJson(Map<String, dynamic> json) => ApiShop(
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

Map<String, dynamic> _$ApiShopToJson(ApiShop instance) => <String, dynamic>{
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
