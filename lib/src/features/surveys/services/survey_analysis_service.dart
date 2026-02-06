import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/surveys/models/survey_analysis.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/surveys/services/branch_users_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyAnalysisService {
  static const String baseUrl = 'https://udbconnect.com/api';

  // Provider for survey analysis data
  static final surveyAnalysisProvider = FutureProvider<SurveyAnalysis>((
    ref,
  ) async {
    print(
      '🔄 [SURVEY ANALYSIS PROVIDER] Provider called - fetching survey analysis data',
    );
    final service = SurveyAnalysisService();
    final token = ref.read(authTokenProvider);
    print(
      '🔑 [SURVEY ANALYSIS PROVIDER] Token retrieved from authTokenProvider',
    );
    return service.fetchSurveyAnalysis(token);
  });

  // Provider for survey analytics data
  static final surveyAnalyticsProvider = FutureProvider<SurveyAnalytics>((
    ref,
  ) async {
    print(
      '🔄 [SURVEY ANALYTICS PROVIDER] Provider called - fetching survey analytics data',
    );
    final service = SurveyAnalysisService();
    final token = ref.read(authTokenProvider);
    print(
      '🔑 [SURVEY ANALYTICS PROVIDER] Token retrieved from authTokenProvider',
    );
    return service.getSurveyAnalytics(token);
  });

  // Provider for survey analysis with branch users data
  static final surveyAnalysisWithUsersProvider =
      FutureProvider<SurveyAnalysisWithUsers>((ref) async {
        print(
          '🔄 [SURVEY ANALYSIS WITH USERS PROVIDER] Provider called - fetching combined data',
        );
        final service = SurveyAnalysisService();
        final token = ref.read(authTokenProvider);
        final userProfile = ref.read(profileProvider);

        return userProfile.when(
          data: (user) async {
            final branchId = user.userBranchId;
            if (branchId == null) {
              throw Exception('User branch ID not found');
            }
            return service.getSurveyAnalysisWithUsers(token, branchId);
          },
          loading: () => throw Exception('User profile is loading'),
          error: (error, stack) =>
              throw Exception('Failed to load user profile: $error'),
        );
      });

  Future<SurveyAnalysis> fetchSurveyAnalysis(String? token) async {
    print('🚀 [SURVEY ANALYSIS API] Starting fetchSurveyAnalysis...');
    print(
      '🔑 [SURVEY ANALYSIS API] Token: ${token != null ? "exists (${token.length} chars)" : "null"}',
    );

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token exists
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 [SURVEY ANALYSIS API] Authorization header added');
      } else {
        print(
          '⚠️ [SURVEY ANALYSIS API] No token provided - request will be unauthenticated',
        );
      }

      final url = '$baseUrl/surveys';
      print('🌐 [SURVEY ANALYSIS API] Making GET request to: $url');
      print('📋 [SURVEY ANALYSIS API] Headers: $headers');

      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(url), headers: headers);
      stopwatch.stop();

      print(
        '⏱️ [SURVEY ANALYSIS API] Request completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      print('📊 [SURVEY ANALYSIS API] Response status: ${response.statusCode}');
      print(
        '📏 [SURVEY ANALYSIS API] Response body length: ${response.body.length} characters',
      );

      if (response.statusCode == 200) {
        print('✅ [SURVEY ANALYSIS API] Success! Parsing response...');
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print(
          '📄 [SURVEY ANALYSIS API] Response structure: ${jsonData.keys.toList()}',
        );

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          final dataList = jsonData['data'] as List;
          print(
            '📊 [SURVEY ANALYSIS API] Found ${dataList.length} survey items in data array',
          );
        }

        final result = SurveyAnalysis.fromJson(jsonData);
        print(
          '🎯 [SURVEY ANALYSIS API] Successfully parsed SurveyAnalysis object',
        );
        return result;
      } else {
        print(
          '❌ [SURVEY ANALYSIS API] Failed with status ${response.statusCode}',
        );
        print('📄 [SURVEY ANALYSIS API] Error response body: ${response.body}');
        throw Exception(
          'Failed to fetch survey analysis: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('💥 [SURVEY ANALYSIS API] Exception occurred: $e');
      print('📚 [SURVEY ANALYSIS API] Exception type: ${e.runtimeType}');
      throw Exception('Error fetching survey analysis: $e');
    }
  }

  // Method to get analytics data for charts
  Future<SurveyAnalytics> getSurveyAnalytics(String? token) async {
    print('📈 [SURVEY ANALYTICS API] Starting getSurveyAnalytics...');
    final surveyAnalysis = await fetchSurveyAnalysis(token);
    print(
      '📊 [SURVEY ANALYTICS API] Creating analytics from ${surveyAnalysis.data.length} surveys',
    );
    final analytics = SurveyAnalytics.fromSurveys(surveyAnalysis.data);
    print('✅ [SURVEY ANALYTICS API] Analytics created successfully');
    return analytics;
  }

  // Method to get survey analysis with branch users data
  Future<SurveyAnalysisWithUsers> getSurveyAnalysisWithUsers(
    String? token,
    int branchId,
  ) async {
    print(
      '📈 [SURVEY ANALYSIS WITH USERS API] Starting getSurveyAnalysisWithUsers for branch: $branchId',
    );

    // Fetch both survey analysis and branch users in parallel
    final futures = await Future.wait([
      fetchSurveyAnalysis(token),
      BranchUsersService().fetchBranchUsers(branchId, token),
    ]);

    final surveyAnalysis = futures[0] as SurveyAnalysis;
    final branchUsers = futures[1] as List;

    print(
      '📊 [SURVEY ANALYSIS WITH USERS API] Found ${surveyAnalysis.data.length} surveys and ${branchUsers.length} users',
    );

    // Filter surveys by the manager's branch
    final filteredSurveys = surveyAnalysis.data
        .where((s) => s.branchId == branchId)
        .toList();
    print(
      '🧹 [SURVEY ANALYSIS WITH USERS API] Filtered surveys for branch $branchId: ${filteredSurveys.length}',
    );

    final filteredSurveyAnalysis = SurveyAnalysis(
      status: surveyAnalysis.status,
      message: surveyAnalysis.message,
      data: filteredSurveys,
    );

    final result = SurveyAnalysisWithUsers(
      surveyAnalysis: filteredSurveyAnalysis,
      totalUsersInBranch: branchUsers.length,
    );

    print(
      '✅ [SURVEY ANALYSIS WITH USERS API] Combined data created successfully',
    );
    return result;
  }
}
