import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';

class SurveyService {
  static const String baseUrl = 'https://udbconnect.com/api';

  // Get auth token
  static Future<String?> _getAuthToken() async {
    final tokenStorage = TokenStorage();
    return await tokenStorage.readToken();
  }

  // Fetch all surveys
  static Future<SurveyApiResponse> fetchSurveys() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/surveys';
      print('🔍 Fetching surveys from: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SurveyApiResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        // Return empty surveys list if endpoint doesn't exist yet
        print('⚠️ Surveys endpoint not found (404), returning empty list');
        return const SurveyApiResponse(
          status: true,
          message: 'No surveys available',
          data: [],
        );
      } else {
        throw Exception(
          'Failed to fetch surveys: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching surveys: $e');
      // Return empty surveys list on error for now
      return SurveyApiResponse(
        status: false,
        message: 'Error fetching surveys: $e',
        data: [],
      );
    }
  }

  // Submit survey response
  static Future<Map<String, dynamic>> submitSurveyResponse({
    required int surveyId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/survey-responses';
      print('🔍 Submitting survey response to: $url');
      print('📝 Survey ID: $surveyId');
      print('📋 Raw answers: $answers');
      print('🔑 Token: ${token.substring(0, 20)}...');

      // Convert answers to the required format: array of {question, answer} objects
      final formattedAnswers = answers.entries
          .map(
            (entry) => {
              'question': entry.key,
              'answer': entry.value.toString(),
            },
          )
          .toList();

      print('📋 Formatted answers: $formattedAnswers');

      final requestBody = {'survey_id': surveyId, 'answers': formattedAnswers};
      print('📦 Final request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Survey response submitted successfully');
        return responseData;
      } else if (response.statusCode == 500) {
        // Handle 500 server errors specifically
        print('❌ Server error (500) - Backend issue');
        throw Exception(
          'Server error: The survey submission failed due to a backend issue. Please try again later.',
        );
      } else if (response.statusCode == 422) {
        // Handle validation errors
        print('❌ Validation error (422)');
        throw Exception(
          'Validation error: Please check your answers and try again.',
        );
      } else if (response.statusCode == 401) {
        // Handle authentication errors
        print('❌ Authentication error (401)');
        throw Exception(
          'Authentication error: Please log in again and try submitting the survey.',
        );
      } else {
        // Handle other errors
        print('❌ Unexpected error: ${response.statusCode}');
        throw Exception(
          'Failed to submit survey response: ${response.statusCode}. Please try again.',
        );
      }
    } catch (e) {
      print('❌ Error submitting survey response: $e');
      throw Exception('Error submitting survey response: $e');
    }
  }

  // Get user's survey responses
  static Future<List<SurveyResponse>> getUserSurveyResponses() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/survey-responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SurveyResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch user survey responses: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching user survey responses: $e');
    }
  }

  // Test survey responses endpoint
  static Future<Map<String, dynamic>> testSurveyResponsesEndpoint() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/survey-responses';
      print('🧪 Testing survey responses endpoint: $url');
      print('🔑 Token: ${token.substring(0, 20)}...');

      // Test with a simple GET request first
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Test response status: ${response.statusCode}');
      print('📄 Test response body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      print('❌ Error testing survey responses endpoint: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update survey status (for future use if needed)
  static Future<Map<String, dynamic>> updateSurveyStatus({
    required int surveyId,
    required String status,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/surveys/$surveyId/status';
      print('🔍 Updating survey status: $url');
      print('📝 Survey ID: $surveyId, Status: $status');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Survey status updated successfully');
        return responseData;
      } else {
        throw Exception(
          'Failed to update survey status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error updating survey status: $e');
      throw Exception('Error updating survey status: $e');
    }
  }
}
