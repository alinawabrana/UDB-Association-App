import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/branch_user_model.dart';
import '../../../../utils/network/retry.dart';

class BranchUsersService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<BranchUser>> fetchBranchUsers({
    required int branchId,
    String? token,
  }) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    final response = await retry(() async {
      return await http
          .get(Uri.parse("$baseUrl/branches/$branchId/users"), headers: headers)
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      // Handle different response formats
      if (data is List) {
        return data.map((json) => BranchUser.fromJson(json)).toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => BranchUser.fromJson(json))
            .toList();
      } else if (data is Map && data['users'] is List) {
        return (data['users'] as List)
            .map((json) => BranchUser.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed to fetch branch users: ${response.body}");
    }
  }

  Future<BranchUsersResponse> fetchBranchUsersWithCounts({
    required int branchId,
    String? token,
  }) async {
    final users = await fetchBranchUsers(branchId: branchId, token: token);
    return BranchUsersResponse.fromUsers(users);
  }
}
