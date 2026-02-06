import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/shop/models/order_model.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/utils/network/retry.dart';

class OrderService {
  static const String baseUrl = 'https://udbconnect.com/api';

  static Future<OrdersResponse> getOrders({int page = 1}) async {
    try {
      final token = await TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/orders?page=$page';

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      if (response.statusCode == 200) {
        // Check if response is HTML (error page)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw Exception(
            'Server returned HTML instead of JSON. This usually means the API endpoint is incorrect or the server is down.',
          );
        }

        final Map<String, dynamic> data = json.decode(response.body);
        return OrdersResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load orders: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception(
          'Invalid response format. The server returned HTML instead of JSON. Please check if the API endpoint is correct.',
        );
      }
      throw Exception('Error fetching orders: $e');
    }
  }

  static Future<OrderModel> getOrderById(int orderId) async {
    try {
      final token = await TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/orders/$orderId';

      print('========== ORDER DETAIL API CALL ==========');
      print('URL: $url');
      print('Order ID: $orderId');
      print('Token: ${token.substring(0, 20)}...');

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('========== END ORDER DETAIL API RESPONSE ==========');

      if (response.statusCode == 200) {
        // Check if response is HTML (error page)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw Exception(
            'Server returned HTML instead of JSON. This usually means the API endpoint is incorrect or the server is down.',
          );
        }

        final Map<String, dynamic> data = json.decode(response.body);
        print('Parsed Order Data: $data');
        return OrderModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load order: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR fetching order detail: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
          'Invalid response format. The server returned HTML instead of JSON. Please check if the API endpoint is correct.',
        );
      }
      throw Exception('Error fetching order: $e');
    }
  }

  static Future<OrdersResponse> getVendorOrders({int page = 1}) async {
    try {
      final token = await TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/vendor/orders?page=$page';

      print('========== VENDOR ORDERS API CALL ==========');
      print('URL: $url');
      print('Token: ${token.substring(0, 20)}...');

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('========== END VENDOR ORDERS API RESPONSE ==========');

      if (response.statusCode == 200) {
        // Check if response is HTML (error page)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw Exception(
            'Server returned HTML instead of JSON. This usually means the API endpoint is incorrect or the server is down.',
          );
        }

        final Map<String, dynamic> data = json.decode(response.body);
        print('Parsed JSON Data: $data');
        return OrdersResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load vendor orders: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR fetching vendor orders: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
          'Invalid response format. The server returned HTML instead of JSON. Please check if the API endpoint is correct.',
        );
      }
      throw Exception('Error fetching vendor orders: $e');
    }
  }
}
