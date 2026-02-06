import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/subscription_booking_model.dart';
import '../../../../utils/network/retry.dart';

class SubscriptionBookingService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<SubscriptionBookingResponse> fetchSubscriptionBookings({
    required String token,
    int page = 1,
  }) async {
    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/subscription-bookings?page=$page"),
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
      return SubscriptionBookingResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to fetch subscription bookings: ${response.body}",
      );
    }
  }
}
