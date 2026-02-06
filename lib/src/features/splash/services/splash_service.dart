import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/splash/models/splash_image.dart';
import 'package:udb_association/utils/network/retry.dart';

class SplashService {
  static const String _baseUrl = 'https://udbconnect.com/api';

  Future<List<SplashImage>> fetchActiveImages() async {
    final uri = Uri.parse('$_baseUrl/splash/active');

    final response = await retry(() async {
      final res = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      _logResponse('GET', uri, res.statusCode, res.body);
      return res;
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load splash images: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded is Map<String, dynamic>
        ? (decoded['data'] as List<dynamic>? ?? const [])
        : (decoded as List<dynamic>? ?? const []);

    return data
        .whereType<Map<String, dynamic>>()
        .map(SplashImage.fromJson)
        .where((img) => img.splashUrl.isNotEmpty)
        .toList();
  }

  void _logResponse(String method, Uri uri, int statusCode, String body) {
    print('[Splash] $method $uri -> $statusCode');
    if (body.length < 500) {
      print('[Splash] Response: $body');
    }
  }
}
