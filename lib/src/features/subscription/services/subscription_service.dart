import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';
import '../../../../utils/network/retry.dart';

class SubscriptionService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<SubscriptionPlan>> fetchSubscriptions() async {
    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/subscriptions"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => SubscriptionPlan.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed to fetch subscriptions: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> processCheckout({
    required String token,
    required int subscriptionId,
    String billingAddress = '',
    required String customerEmail,
    required String customerName,
    required String phone,
    required String businessName,
    required String shopTagline,
    required String shopDetail,
    required String paymentMethod,
    required String paymentMethodId,
  }) async {
    final payload = {
      "address": billingAddress,
      "email": customerEmail,
      "name": customerName,
      "phone": phone,
      "business_name": businessName,
      "shop_tagline": shopTagline,
      "shop_details": shopDetail,
      "payment_method": paymentMethod,
      "payment_method_id": paymentMethodId,
    };

    print('SUBSCRIPTION CHECKOUT PAYLOAD: $payload');

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/subscriptions/$subscriptionId/checkout"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));
    });

    print('SUBSCRIPTION CHECKOUT RESPONSE STATUS: ${response.statusCode}');
    print('SUBSCRIPTION CHECKOUT RESPONSE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Checkout failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> submitMemberRequest({
    required String token,
    required int subscriptionId,
    required int branchId,
  }) async {
    final payload = {"subscription_id": subscriptionId, "branch_id": branchId};

    print('MEMBER REQUEST PAYLOAD: $payload');

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/user/submit-member-request"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));
    });

    print('MEMBER REQUEST RESPONSE STATUS: ${response.statusCode}');
    print('MEMBER REQUEST RESPONSE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Member request failed: ${response.body}");
    }
  }

  /// Process user subscription checkout (for role = user)
  Future<Map<String, dynamic>> processUserSubscriptionCheckout({
    required String token,
    required int subscriptionId,
  }) async {
    print('USER SUBSCRIPTION CHECKOUT: subscriptionId=$subscriptionId');

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/user/subscriptions/$subscriptionId/checkout"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 25));
    });

    print('USER SUBSCRIPTION CHECKOUT RESPONSE STATUS: ${response.statusCode}');
    print('USER SUBSCRIPTION CHECKOUT RESPONSE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("User subscription checkout failed: ${response.body}");
    }
  }
}
