import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user_subscription_request_model.dart';
import '../../../../utils/network/retry.dart';

class UserSubscriptionRequestService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<UserSubscriptionRequestResponse> fetchUserSubscriptionRequests({
    required String token,
  }) async {
    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/user-subscription-requests"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return UserSubscriptionRequestResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to fetch user subscription requests: ${response.body}",
      );
    }
  }
}
