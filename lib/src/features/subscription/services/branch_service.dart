import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/branch_model.dart';
import '../../../../utils/network/retry.dart';

class BranchService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<Branch>> fetchBranches({String? token}) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    final response = await retry(() async {
      return await http
          .get(Uri.parse("$baseUrl/branches"), headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => Branch.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Branch.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed to fetch branches: ${response.body}");
    }
  }
}
