import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/shop/models/review_model.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/utils/network/retry.dart';

class ReviewService {
  static const String baseUrl = 'https://udbconnect.com/api';

  /// Submit a review for a product
  ///
  /// Parameters:
  /// - productId: The ID of the product to review
  /// - rating: Required rating (1-5)
  /// - reviewText: Optional review comment
  /// - title: Optional review title
  static Future<ReviewModel> submitReview({
    required int productId,
    required int rating,
    String? reviewText,
    String? title,
  }) async {
    try {
      final token = await TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/products/$productId/reviews';

      // Build request body
      final Map<String, dynamic> body = {'rating': rating};

      // Add optional fields only if they're not null and not empty
      if (reviewText != null && reviewText.trim().isNotEmpty) {
        body['review_text'] = reviewText.trim();
      }

      if (title != null && title.trim().isNotEmpty) {
        body['title'] = title.trim();
      }

      print('🔍 Submitting review to: $url');
      print('📝 Request body: $body');

      final response = await retry(() async {
        return await http
            .post(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 15));
      });

      print('✅ Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if response is HTML (error page)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw Exception(
            'Server returned HTML instead of JSON. This usually means the API endpoint is incorrect or the server is down.',
          );
        }

        final Map<String, dynamic> data = json.decode(response.body);
        return ReviewModel.fromJson(data);
      } else {
        // Parse error response
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Failed to submit review';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception(
            'Failed to submit review: ${response.statusCode}. ${response.body}',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception(
          'Invalid response format. The server returned HTML instead of JSON. Please check if the API endpoint is correct.',
        );
      }
      rethrow;
    }
  }

  /// Get reviews for a product
  static Future<ProductReviewsResponse> getProductReviews(int productId) async {
    try {
      final token = await TokenStorage().readToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/products/$productId/reviews';

      print('🔍 Fetching reviews for product $productId from: $url');

      final response = await retry(() async {
        return await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));
      });

      print('✅ Reviews response status: ${response.statusCode}');
      print('📄 Reviews response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductReviewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching reviews: $e');
      rethrow;
    }
  }
}
