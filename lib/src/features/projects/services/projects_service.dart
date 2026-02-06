import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../../../../utils/network/retry.dart';
import '../../../../src/common/storage/token_storage.dart';

class ProjectsService {
  static const baseUrl = "https://udbconnect.com/api";
  final TokenStorage _tokenStorage = const TokenStorage();

  Future<ProjectsResponse> fetchProjects() async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      throw Exception("No authentication token found");
    }

    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/projects"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ProjectsResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch projects: ${response.body}");
    }
  }
}
