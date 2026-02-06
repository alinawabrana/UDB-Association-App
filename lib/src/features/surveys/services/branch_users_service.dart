import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';

class BranchUsersService {
  static const String baseUrl = 'https://udbconnect.com/api';

  // Provider for branch users data
  static final branchUsersProvider = FutureProvider.family<List<User>, int>((
    ref,
    branchId,
  ) async {
    print(
      '🔄 [BRANCH USERS PROVIDER] Provider called - fetching users for branch: $branchId',
    );
    final service = BranchUsersService();
    final token = ref.read(authTokenProvider);
    print('🔑 [BRANCH USERS PROVIDER] Token retrieved from authTokenProvider');
    return service.fetchBranchUsers(branchId, token);
  });

  Future<List<User>> fetchBranchUsers(int branchId, String? token) async {
    print(
      '🚀 [BRANCH USERS API] Starting fetchBranchUsers for branch: $branchId',
    );
    print(
      '🔑 [BRANCH USERS API] Token: ${token != null ? "exists (${token.length} chars)" : "null"}',
    );

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token exists
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 [BRANCH USERS API] Authorization header added');
      } else {
        print(
          '⚠️ [BRANCH USERS API] No token provided - request will be unauthenticated',
        );
      }

      final url = '$baseUrl/branches/$branchId/users';
      print('🌐 [BRANCH USERS API] Making GET request to: $url');
      print('📋 [BRANCH USERS API] Headers: $headers');

      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(url), headers: headers);
      stopwatch.stop();

      print(
        '⏱️ [BRANCH USERS API] Request completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      print('📊 [BRANCH USERS API] Response status: ${response.statusCode}');
      print(
        '📏 [BRANCH USERS API] Response body length: ${response.body.length} characters',
      );

      if (response.statusCode == 200) {
        print('✅ [BRANCH USERS API] Success! Parsing response...');
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print(
          '📄 [BRANCH USERS API] Response structure: ${jsonData.keys.toList()}',
        );

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          final dataList = jsonData['data'] as List;
          print(
            '📊 [BRANCH USERS API] Found ${dataList.length} users in data array',
          );
        }

        // Parse the response data
        final List<dynamic> usersData = jsonData['data'] ?? [];
        final List<User> users = usersData
            .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
            .toList();

        print(
          '🎯 [BRANCH USERS API] Successfully parsed ${users.length} users',
        );
        return users;
      } else {
        print('❌ [BRANCH USERS API] Failed with status ${response.statusCode}');
        print('📄 [BRANCH USERS API] Error response body: ${response.body}');
        throw Exception('Failed to fetch branch users: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [BRANCH USERS API] Exception occurred: $e');
      print('📚 [BRANCH USERS API] Exception type: ${e.runtimeType}');
      throw Exception('Error fetching branch users: $e');
    }
  }
}
