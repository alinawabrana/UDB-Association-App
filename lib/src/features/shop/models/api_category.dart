import 'package:json_annotation/json_annotation.dart';
import '../../../../utils/constants/urls.dart';

part 'api_category.g.dart';

@JsonSerializable()
class ApiCategory {
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
  final List<ApiCategory>? children;

  const ApiCategory({
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
    this.children,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) =>
      _$ApiCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ApiCategoryToJson(this);

  String? get fullImageUrl => ApiUrls.getCategoryImageUrl(image);
}
