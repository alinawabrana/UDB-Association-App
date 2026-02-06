import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_category.dart';
import '../models/api_product.dart';
import '../models/api_products_response.dart';
import '../models/product_detail_response.dart';
import '../models/cart_item.dart';
import '../../../../utils/constants/urls.dart';
import '../../../../utils/network/retry.dart';

class ApiService {
  static const String baseUrl = 'https://udbconnect.com/api';

  static Future<List<ApiCategory>> fetchCategories() async {
    try {
      print('=== CATEGORIES API REQUEST ===');
      print('URL: $baseUrl/categories');

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/categories'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('=== CATEGORIES API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final categories = jsonData
            .map((category) => ApiCategory.fromJson(category))
            .toList();

        print('=== PARSED CATEGORIES ===');
        print('Categories count: ${categories.length}');
        for (int i = 0; i < categories.length; i++) {
          print('Category $i: ${categories[i].toJson()}');
        }
        print('=== END CATEGORIES RESPONSE ===');

        return categories;
      } else {
        print('=== CATEGORIES API ERROR ===');
        print('Failed to load categories: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('=== END CATEGORIES API ERROR ===');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('=== CATEGORIES API EXCEPTION ===');
      print('Error: $e');
      print('=== END CATEGORIES API EXCEPTION ===');
      rethrow;
    }
  }

  static Future<ApiProductsResponse> fetchProducts({
    int page = 1,
    int perPage = 12,
    int? categoryId,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await retry(() async {
        return await http
            .get(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 20));
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiProductsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ApiProduct>> fetchAllProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      final response = await fetchProducts(
        categoryId: categoryId,
        search: search,
        perPage: 100, // Fetch more items per page
      );
      return response.data;
    } catch (e) {
      throw Exception('Error fetching all products: $e');
    }
  }

  static Future<ProductDetailResponse> fetchProductDetail(int productId) async {
    try {
      print('Fetching product detail for ID: $productId');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/products/$productId'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 20));
      });

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        // The API response structure is exactly as expected:
        // {"product": {...}, "avg_rating": 0, "user_review": null, "related_products": [...]}
        return ProductDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Product not found (ID: $productId)');
      } else {
        throw Exception(
          'Failed to load product detail: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in fetchProductDetail: $e');
      rethrow;
    }
  }

  // Method to get primary image URL for a product by ID
  static Future<String?> getProductPrimaryImage(int productId) async {
    try {
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/products/$productId'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;

        final productData = jsonData['product'];
        if (productData != null && productData['images'] != null) {
          final List<dynamic> images = productData['images'];
          if (images.isNotEmpty) {
            final firstImage = images.first;
            if (firstImage != null && firstImage['image_url'] != null) {
              return ApiUrls.getProductImageUrl(firstImage['image_url']);
            }
          }
        }
      }
    } catch (e) {
      // swallow and return null on error
    }
    return null;
  }

  /// Add a product to cart
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required String authToken,
    int quantity = 1,
  }) async {
    try {
      print('🛒 Adding product $productId to cart with quantity $quantity');
      final response = await retry(() async {
        return await http
            .post(
              Uri.parse('$baseUrl/products/$productId/add-to-cart'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode({'quantity': quantity}),
            )
            .timeout(const Duration(seconds: 20));
      });

      print('📊 Add to cart response status: ${response.statusCode}');
      print('📄 Add to cart response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully added to cart: $responseData');
        return responseData;
      } else {
        print(
          '❌ Failed to add to cart: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to add to cart: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error adding to cart: $e');
      rethrow;
    }
  }

  /// Fetch cart items and count
  static Future<dynamic> fetchCart({required String authToken}) async {
    try {
      print('🛒 Fetching cart data...');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/cart'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('📊 Fetch cart response status: ${response.statusCode}');
      print('📄 Fetch cart response body: ${response.body}');

      if (response.statusCode == 200) {
        final cartData = jsonDecode(response.body);
        print('✅ Successfully fetched cart: $cartData');
        return cartData;
      } else {
        print(
          '❌ Failed to fetch cart: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch cart: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error fetching cart: $e');
      rethrow;
    }
  }

  /// Fetch cart items as a list
  static Future<List<CartItem>> fetchCartItems({
    required String authToken,
  }) async {
    try {
      print('🛒 Fetching cart items list...');
      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/cart'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('📊 Fetch cart items response status: ${response.statusCode}');
      print('📄 Fetch cart items response body: ${response.body}');

      if (response.statusCode == 200) {
        final cartData = jsonDecode(response.body);
        print('✅ Successfully fetched cart items: $cartData');

        // Extract cart items from response
        List<dynamic> cartItems = [];

        // Handle case where API returns empty list instead of cart object
        if (cartData is List) {
          cartItems = cartData;
        } else if (cartData is Map<String, dynamic>) {
          if (cartData.containsKey('items') && cartData['items'] is List) {
            cartItems = cartData['items'] as List;
          } else if (cartData.containsKey('data') && cartData['data'] is List) {
            cartItems = cartData['data'] as List;
          }
        }

        final items = cartItems
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();

        print('📋 Parsed ${items.length} cart items');
        return items;
      } else {
        print(
          '❌ Failed to fetch cart items: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch cart items: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error fetching cart items: $e');
      rethrow;
    }
  }

  /// Get cart items count only
  static Future<int> getCartItemsCount({required String authToken}) async {
    try {
      final cartData = await fetchCart(authToken: authToken);

      // Handle case where API returns empty list instead of cart object
      if (cartData is List) {
        return cartData.length;
      } else {
        // Extract count from response - adjust based on actual API response structure
        if (cartData is Map &&
            cartData.containsKey('data') &&
            cartData['data'] is List) {
          return (cartData['data'] as List).length;
        } else if (cartData is Map &&
            cartData.containsKey('items') &&
            cartData['items'] is List) {
          return (cartData['items'] as List).length;
        } else if (cartData is Map && cartData.containsKey('count')) {
          return cartData['count'] as int;
        } else {
          return 0;
        }
      }
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  /// Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    required String authToken,
    required int quantity,
  }) async {
    try {
      print('🔄 Updating cart item $itemId with quantity $quantity');
      final response = await retry(() async {
        return await http
            .put(
              Uri.parse('$baseUrl/cart/items/$itemId'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode({'quantity': quantity}),
            )
            .timeout(const Duration(seconds: 20));
      });

      print('📊 Update cart item response status: ${response.statusCode}');
      print('📄 Update cart item response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully updated cart item: $responseData');
        return responseData;
      } else {
        print(
          '❌ Failed to update cart item: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to update cart item: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error updating cart item: $e');
      rethrow;
    }
  }

  /// Delete a cart item completely
  static Future<Map<String, dynamic>> deleteCartItem({
    required int itemId,
    required String authToken,
  }) async {
    try {
      print('🗑️ Deleting cart item $itemId');
      final response = await retry(() async {
        return await http
            .delete(
              Uri.parse('$baseUrl/cart/items/$itemId'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('📊 Delete cart item response status: ${response.statusCode}');
      print('📄 Delete cart item response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Item deleted successfully'};
        print('✅ Successfully deleted cart item: $responseData');
        return responseData;
      } else {
        print(
          '❌ Failed to delete cart item: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to delete cart item: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error deleting cart item: $e');
      rethrow;
    }
  }

  // Shipping Address API Methods
  static Future<List<Map<String, dynamic>>> fetchShippingAddresses({
    required String authToken,
  }) async {
    try {
      print('🚚 Fetching shipping addresses...');

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse('$baseUrl/shipping-addresses'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print(
        '📊 Fetch shipping addresses response status: ${response.statusCode}',
      );
      print('📄 Fetch shipping addresses response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final addresses = jsonData.cast<Map<String, dynamic>>();
        print('✅ Successfully fetched ${addresses.length} shipping addresses');
        return addresses;
      } else {
        print(
          '❌ Failed to fetch shipping addresses: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch shipping addresses: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error fetching shipping addresses: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createShippingAddress({
    required String authToken,
    required String firstName,
    required String lastName,
    required String addressLine1,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phone,
    bool? isDefault,
  }) async {
    try {
      print('🚚 Creating shipping address...');

      final requestBody = {
        'first_name': firstName,
        'last_name': lastName,
        'address_line1': addressLine1,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
        if (zipCode != null && zipCode.isNotEmpty) 'zip_code': zipCode,
        if (country != null && country.isNotEmpty) 'country': country,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (isDefault != null) 'is_default': isDefault,
      };

      print('📤 Request body: $requestBody');

      final response = await retry(() async {
        return await http
            .post(
              Uri.parse('$baseUrl/shipping-addresses'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: json.encode(requestBody),
            )
            .timeout(const Duration(seconds: 15));
      });

      print(
        '📊 Create shipping address response status: ${response.statusCode}',
      );
      print('📄 Create shipping address response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Successfully created shipping address: $responseData');
        return responseData;
      } else {
        print(
          '❌ Failed to create shipping address: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to create shipping address: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error creating shipping address: $e');
      rethrow;
    }
  }

  // Checkout API Method
  static Future<Map<String, dynamic>> processCheckout({
    required String authToken,
    required int shippingAddressId,
    String? paymentMethod,
    List<int>? selectedCartItemIds,
  }) async {
    try {
      print('🛒 Processing checkout...');
      print('📦 Selected cart item IDs: $selectedCartItemIds');

      final requestBody = {
        'shipping_address_id': shippingAddressId,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (selectedCartItemIds != null && selectedCartItemIds.isNotEmpty)
          'selected_cart_item_ids': selectedCartItemIds,
      };

      print('📤 Checkout request body: ${json.encode(requestBody)}');

      final response = await retry(() async {
        return await http
            .post(
              Uri.parse('$baseUrl/checkout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: json.encode(requestBody),
            )
            .timeout(const Duration(seconds: 15));
      });

      print('📊 Checkout response status: ${response.statusCode}');
      print('📄 Checkout response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Successfully processed checkout: $responseData');
        return responseData;
      } else {
        print(
          '❌ Failed to process checkout: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to process checkout: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Error processing checkout: $e');
      rethrow;
    }
  }
}
