// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCategory _$ApiCategoryFromJson(Map<String, dynamic> json) => ApiCategory(
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
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ApiCategoryToJson(ApiCategory instance) =>
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
      'children': instance.children,
    };
