import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/shop.dart';
import '../models/api_category.dart';
import '../models/api_product.dart';
import '../../../../utils/network/retry.dart';

class ShopApiService {
  static const String baseUrl = 'https://udbconnect.com/api';

  /// Fetch all shops
  static Future<List<Shop>> fetchShops() async {
    print('ShopApiService: Fetching shops list');
    try {
      final url = '$baseUrl/shops';
      print('ShopApiService: Making request to: $url');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print(
        'ShopApiService: Shops response status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        print('ShopApiService: Successfully fetched shops from API');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> shops = responseData['data'] ?? [];
        return shops.map((json) => Shop.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shops: ${response.statusCode}');
      }
    } catch (e) {
      print('ShopApiService: Error fetching shops: $e');
      rethrow;
    }
  }

  /// Fetch products for a specific shop
  static Future<List<ApiProduct>> fetchShopProducts(int shopId) async {
    print('ShopApiService: Fetching products for shop ID: $shopId');
    try {
      final url = '$baseUrl/shops/$shopId/products';
      print('ShopApiService: Making request to: $url');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('ShopApiService: Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('ShopApiService: Successfully fetched products from API');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> products = responseData['data'] ?? [];
        return products.map((json) => ApiProduct.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shop products: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'ShopApiService: Error fetching shop products for shop $shopId: $e',
      );
      rethrow;
    }
  }

  /// Fetch categories for a specific shop
  static Future<List<ApiCategory>> fetchShopCategories(int shopId) async {
    print('ShopApiService: Fetching categories for shop ID: $shopId');
    try {
      final url = '$baseUrl/shops/$shopId/categories';
      print('ShopApiService: Making request to: $url');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print(
        'ShopApiService: Categories response status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        print('ShopApiService: Successfully fetched categories from API');
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ApiCategory.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load shop categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'ShopApiService: Error fetching shop categories for shop $shopId: $e',
      );
      rethrow;
    }
  }
}
