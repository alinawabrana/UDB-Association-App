import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../../../../utils/network/retry.dart';

class LocationService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<Location>> fetchLocations({String? token}) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    final response = await retry(() async {
      return await http
          .get(Uri.parse("$baseUrl/locations"), headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return Location.listFromJson(data as Map<String, dynamic>);
    } else {
      throw Exception("Failed to fetch locations: ${response.body}");
    }
  }
}

