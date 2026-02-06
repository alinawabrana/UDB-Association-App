import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../../../../utils/network/retry.dart';

class NewsService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<NewsModel>> fetchNews(String token) async {
    final uri = Uri.parse("$baseUrl/news");
    print('📰 [NEWS SERVICE] Fetching news...');
    print('   URL: $uri');
    print('   Timestamp: ${DateTime.now().toIso8601String()}');
    
    final response = await retry(() async {
      return await http
          .get(
            uri,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 20));
    });

    print('📰 [NEWS SERVICE] Response received:');
    print('   Status Code: ${response.statusCode}');
    print('   Response Body Length: ${response.body.length}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final List<dynamic> newsJson = data['data'] ?? [];
      
      print('📰 [NEWS SERVICE] Successfully parsed news:');
      print('   News Count: ${newsJson.length}');
      
      final newsList = newsJson
          .map(
            (newsJson) => NewsModel.fromJson(newsJson as Map<String, dynamic>),
          )
          .toList();
      
      print('📰 [NEWS SERVICE] News fetched successfully!');
      return newsList;
    } else {
      print('❌ [NEWS SERVICE] Failed to fetch news:');
      print('   Error: ${response.body}');
      throw Exception("Failed to fetch news: ${response.body}");
    }
  }
}
