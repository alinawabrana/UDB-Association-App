import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/features/surveys/services/survey_service.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';

// Provider for fetching surveys
final surveysProvider = FutureProvider<List<Survey>>((ref) async {
  final response = await SurveyService.fetchSurveys();
  return response.data;
});

// Provider for user's survey responses
final userSurveyResponsesProvider = FutureProvider<List<SurveyResponse>>((
  ref,
) async {
  return await SurveyService.getUserSurveyResponses();
});

// Provider for selected survey category
final selectedSurveyCategoryProvider = StateProvider<SurveyCategory>((ref) {
  return SurveyCategory.all;
});

// Provider to check if current user has submitted a specific survey
final userSurveySubmissionProvider = Provider.family<AsyncValue<bool>, int>((
  ref,
  surveyId,
) {
  final surveysAsync = ref.watch(surveysProvider);
  final userProfileAsync = ref.watch(profileProvider);

  return surveysAsync.when(
    data: (surveys) {
      return userProfileAsync.when(
        data: (user) {
          // Get current user ID (both string and int)
          final currentUserIdString = user.id;
          final currentUserIdInt = int.tryParse(user.id ?? '');

          if (currentUserIdString == null && currentUserIdInt == null) {
            print('⚠️ Could not get user ID: ${user.id}');
            return const AsyncValue.data(false);
          }

          // Find the specific survey
          final survey = surveys.firstWhere(
            (s) => s.id == surveyId,
            orElse: () => throw Exception('Survey not found'),
          );

          // Check if user has submitted this survey by looking at survey responses
          final hasSubmitted = survey.responses.any((response) {
            // Check both string and int matches
            final stringMatch =
                currentUserIdString != null &&
                response.userId.toString() == currentUserIdString;
            final intMatch =
                currentUserIdInt != null && response.userId == currentUserIdInt;
            return stringMatch || intMatch;
          });

          print(
            '🔍 User $currentUserIdString/$currentUserIdInt has submitted survey $surveyId: $hasSubmitted',
          );
          return AsyncValue.data(hasSubmitted);
        },
        loading: () => AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for filtered surveys based on category and branch
final filteredSurveysProvider = Provider<AsyncValue<List<Survey>>>((ref) {
  final surveysAsync = ref.watch(surveysProvider);
  final selectedCategory = ref.watch(selectedSurveyCategoryProvider);
  final userProfileAsync = ref.watch(profileProvider);

  return surveysAsync.when(
    data: (surveys) {
      return userProfileAsync.when(
        data: (user) {
          // Get user's branch ID
          final userBranchId = user.userBranchId;
          print('🔍 User branch ID: $userBranchId');

          // Filter surveys by user's branch ID
          List<Survey> branchFilteredSurveys = surveys;
          if (userBranchId != null) {
            branchFilteredSurveys = surveys
                .where((survey) => survey.branchId == userBranchId)
                .toList();
            print(
              '🔍 Branch filtered surveys: ${branchFilteredSurveys.length} out of ${surveys.length}',
            );
          } else {
            print('⚠️ User has no branch ID, showing all surveys');
          }

          // Get current user ID for completion check
          final currentUserIdString = user.id;
          final currentUserIdInt = int.tryParse(user.id ?? '');
          print('🔍 Current user ID (string): $currentUserIdString');
          print('🔍 Current user ID (int): $currentUserIdInt');
          print('🔍 User ID type: ${user.id.runtimeType}');
          print('🔍 User ID raw: ${user.id}');

          List<Survey> filteredSurveys;
          switch (selectedCategory) {
            case SurveyCategory.completed:
              // Show surveys that are completed by current user AND are active
              filteredSurveys = branchFilteredSurveys.where((survey) {
                print('🔍 Checking survey ${survey.id}: ${survey.title}');
                print('🔍 Survey responses count: ${survey.responses.length}');

                for (final response in survey.responses) {
                  print(
                    '🔍 Response user ID: ${response.userId} (type: ${response.userId.runtimeType})',
                  );
                  print('🔍 Current user ID (string): $currentUserIdString');
                  print('🔍 Current user ID (int): $currentUserIdInt');

                  // Check both string and int matches
                  final stringMatch =
                      currentUserIdString != null &&
                      response.userId.toString() == currentUserIdString;
                  final intMatch =
                      currentUserIdInt != null &&
                      response.userId == currentUserIdInt;
                  print('🔍 String match: $stringMatch');
                  print('🔍 Int match: $intMatch');
                }

                final isCompleted = survey.responses.any((response) {
                  // Check both string and int matches
                  final stringMatch =
                      currentUserIdString != null &&
                      response.userId.toString() == currentUserIdString;
                  final intMatch =
                      currentUserIdInt != null &&
                      response.userId == currentUserIdInt;
                  return stringMatch || intMatch;
                });
                final isActive = survey.status == 'active';
                print(
                  '🔍 Survey ${survey.id} - isCompleted: $isCompleted, isActive: $isActive',
                );
                return isCompleted && isActive;
              }).toList();
              break;
            case SurveyCategory.uncompleted:
              // Show surveys that are NOT completed by current user OR are inactive/expired
              filteredSurveys = branchFilteredSurveys.where((survey) {
                final isCompleted = survey.responses.any((response) {
                  // Check both string and int matches
                  final stringMatch =
                      currentUserIdString != null &&
                      response.userId.toString() == currentUserIdString;
                  final intMatch =
                      currentUserIdInt != null &&
                      response.userId == currentUserIdInt;
                  return stringMatch || intMatch;
                });
                final isActive = survey.status == 'active';
                return !isCompleted || !isActive;
              }).toList();
              break;
            case SurveyCategory.all:
              // Show all surveys for the user's branch
              filteredSurveys = branchFilteredSurveys;
              break;
          }

          print(
            '🔍 Filtered surveys for ${selectedCategory.name}: ${filteredSurveys.length}',
          );
          return AsyncValue.data(filteredSurveys);
        },
        loading: () => AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for survey submission
final surveySubmissionProvider =
    StateNotifierProvider<SurveySubmissionNotifier, AsyncValue<void>>((ref) {
      return SurveySubmissionNotifier(ref);
    });

class SurveySubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SurveySubmissionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitSurvey({
    required int surveyId,
    required Map<String, dynamic> answers,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Get current user info for debugging
      final userProfileAsync = ref.read(profileProvider);
      userProfileAsync.when(
        data: (user) {
          print('🔍 Submitting survey for user ID: ${user.id}');
          print('🔍 User ID type: ${user.id.runtimeType}');
        },
        loading: () => print('🔍 User profile loading...'),
        error: (error, stack) => print('🔍 User profile error: $error'),
      );

      // Submit the survey response
      final result = await SurveyService.submitSurveyResponse(
        surveyId: surveyId,
        answers: answers,
      );

      print('✅ Survey submission successful: $result');

      // Optionally update survey status to "completed"
      // Note: This might be handled automatically by the backend
      try {
        await SurveyService.updateSurveyStatus(
          surveyId: surveyId,
          status: 'completed',
        );
        print('✅ Survey status updated to completed');
      } catch (statusError) {
        // If status update fails, it's not critical - the response was still submitted
        print('⚠️ Could not update survey status: $statusError');
      }

      // Refresh surveys to update the UI with new responses
      ref.invalidate(surveysProvider);

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      print('❌ Survey submission failed: $error');
      state = AsyncValue.error(error, stack);
    }
  }
}
