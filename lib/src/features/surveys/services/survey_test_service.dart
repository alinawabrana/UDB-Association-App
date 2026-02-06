import 'package:http/http.dart' as http;
import 'package:udb_association/src/common/storage/token_storage.dart';

class SurveyTestService {
  static const String baseUrl = 'https://udbconnect.com/api';

  // Test if surveys endpoint exists
  static Future<Map<String, dynamic>> testSurveysEndpoint() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.readToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'No authentication token found',
          'statusCode': 401,
        };
      }

      final url = '$baseUrl/surveys';
      print('🧪 Testing surveys endpoint: $url');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📄 Response body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers,
        'url': url,
      };
    } catch (e) {
      print('❌ Error testing surveys endpoint: $e');
      return {'success': false, 'error': e.toString(), 'statusCode': 0};
    }
  }

  // Test other endpoints to see what's available
  static Future<Map<String, dynamic>> testAvailableEndpoints() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.readToken();

      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }

      final endpoints = [
        '/surveys',
        '/news',
        '/events',
        '/documents',
        '/notifications',
        '/user',
        '/profile',
      ];

      final results = <String, Map<String, dynamic>>{};

      for (final endpoint in endpoints) {
        try {
          final url = '$baseUrl$endpoint';
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          results[endpoint] = {
            'statusCode': response.statusCode,
            'success': response.statusCode == 200,
            'bodyLength': response.body.length,
          };
        } catch (e) {
          results[endpoint] = {
            'statusCode': 0,
            'success': false,
            'error': e.toString(),
          };
        }
      }

      return {'success': true, 'results': results};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
