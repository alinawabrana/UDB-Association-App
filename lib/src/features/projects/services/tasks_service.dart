import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../../../../utils/network/retry.dart';
import '../../../../src/common/storage/token_storage.dart';

class TasksService {
  static const baseUrl = "https://udbconnect.com/api";
  final TokenStorage _tokenStorage = const TokenStorage();

  Future<TasksResponse> fetchTasks() async {
    print('🔍 === FETCHING TASKS ===');
    final token = await _tokenStorage.readToken();

    if (token == null) {
      print('❌ No authentication token found');
      throw Exception("No authentication token found");
    }

    print('✅ Token found, making API request...');

    try {
      final response = await retry(() async {
        print('📡 Making HTTP request to: $baseUrl/tasks');
        return await http
            .get(
              Uri.parse("$baseUrl/tasks"),
              headers: {
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('📊 Response status code: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          print('✅ JSON decoded successfully');
          print('📋 Tasks API Response: $data');

          final tasksResponse = TasksResponse.fromJson(data);
          print('✅ TasksResponse created successfully');
          print('📊 Tasks count: ${tasksResponse.data.length}');

          return tasksResponse;
        } catch (jsonError) {
          print('❌ JSON parsing error: $jsonError');
          print('📄 Raw response body: ${response.body}');
          throw Exception("Failed to parse JSON response: $jsonError");
        }
      } else {
        print('❌ Tasks API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          "Failed to fetch tasks: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print('❌ Tasks Service Error: $e');
      print('📊 Error type: ${e.runtimeType}');
      if (e is Exception) {
        print('📊 Exception details: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<TaskStatusUpdateResponse> updateTaskStatus(
    int taskId,
    String status,
  ) async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      throw Exception("No authentication token found");
    }

    final response = await retry(() async {
      return await http
          .patch(
            Uri.parse("$baseUrl/tasks/$taskId/status"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 15));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return TaskStatusUpdateResponse.fromJson(data);
    } else {
      throw Exception("Failed to update task status: ${response.body}");
    }
  }
}
