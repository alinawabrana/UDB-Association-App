import 'package:json_annotation/json_annotation.dart';
import 'api_product.dart';

part 'api_products_response.g.dart';

@JsonSerializable()
class ApiProductsResponse {
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<ApiProduct> data;
  @JsonKey(name: 'first_page_url')
  final String firstPageUrl;
  final int? from;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'last_page_url')
  final String lastPageUrl;
  final List<dynamic>? links;
  @JsonKey(name: 'next_page_url')
  final String? nextPageUrl;
  final String path;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'prev_page_url')
  final String? prevPageUrl;
  final int? to;
  final int total;

  const ApiProductsResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory ApiProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiProductsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiProductsResponseToJson(this);
}
