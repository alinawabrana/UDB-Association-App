import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/surveys/services/survey_analysis_service.dart';
import 'package:udb_association/src/features/surveys/models/survey_analysis.dart';

class AllSurveysScreen extends ConsumerWidget {
  const AllSurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final surveyAnalysisWithUsersAsync = ref.watch(
      SurveyAnalysisService.surveyAnalysisWithUsersProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 65,
        title: Text(
          l10n.translate('all_surveys_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: surveyAnalysisWithUsersAsync.when(
        data: (surveyAnalysisWithUsers) {
          final allSurveys = surveyAnalysisWithUsers.surveysWithCompletion;
          // TODO: In a real implementation, you would fetch manager user IDs from an API
          final managerUserIds = <int>[40, 53]; // Manager user IDs to exclude

          if (allSurveys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 80, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('all_surveys_empty_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('all_surveys_empty_subtitle'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  l10n.translate('all_surveys_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate(
                    allSurveys.length == 1
                        ? 'all_surveys_count_single'
                        : 'all_surveys_count_plural',
                    params: {'count': allSurveys.length.toString()},
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                // Survey cards
                ...allSurveys.asMap().entries.map((entry) {
                  final index = entry.key;
                  final survey = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < allSurveys.length - 1 ? 16 : 0,
                    ),
                    child: _buildSurveyCard(
                      l10n,
                      survey,
                      index,
                      managerUserIds,
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
          );
        },
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('all_surveys_error_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurveyCard(
    AppLocalizations l10n,
    SurveyAnalysisDataWithCompletion surveyWithCompletion,
    int index,
    List<int> managerUserIds,
  ) {
    final survey = surveyWithCompletion.survey;
    final colors = [
      const Color(0xFF6B8E23), // Green
      const Color(0xFF1E40AF), // Blue
      const Color(0xFFF97316), // Orange
    ];
    final color = colors[index % colors.length];

    // Get non-manager response count
    final nonManagerResponseCount = survey.getTotalResponsesExcludingManagers(
      managerUserIds,
    );

    // Calculate non-manager user count (total users minus managers)
    final nonManagerUserCount =
        surveyWithCompletion.totalUsersInBranch - managerUserIds.length;

    // Get the correct completion rate excluding managers
    final actualCompletionRate = surveyWithCompletion
        .getActualCompletionRateExcludingManagers(managerUserIds);

    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and completion rate
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '${actualCompletionRate.toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Questions and responses
          Text(
            l10n.translate(
              'survey_analysis_questions_responses',
              params: {
                'questions': survey.totalQuestions.toString(),
                'responses': nonManagerResponseCount.toString(),
                'total': nonManagerUserCount.toString(),
              },
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 12),

          // Completion rate row
          Row(
            children: [
              Text(
                l10n.translate('survey_analysis_completion_rate'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                '${actualCompletionRate.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB), // Grayish background color
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF9CA3AF), width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: actualCompletionRate / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Status and action
          Row(
            children: [
              Text(
                survey.statusText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              // const Spacer(),
              // TextButton(
              //   onPressed: () {
              //     // Handle action
              //   },
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //     minimumSize: Size.zero,
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   child: Text(
              //     surveyWithCompletion.completionStatusText,
              //     style: TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w400,
              //       color: color,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
