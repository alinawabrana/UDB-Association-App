import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/features/surveys/services/survey_analysis_service.dart';
import 'package:udb_association/src/features/surveys/models/survey_analysis.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/common/widgets/app_drawer.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';

class SurveyAnalysisScreen extends ConsumerWidget {
  const SurveyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    print('🏗️ [SURVEY ANALYSIS SCREEN] Building SurveyAnalysisScreen...');
    print('📋 [SURVEY ANALYSIS SCREEN] APIs that will be called:');
    print('   1. Survey Analysis API: GET https://udbconnect.com/api/surveys');
    print(
      '   2. User Profile API: GET https://udbconnect.com/api/user/profile',
    );
    print(
      '   3. Profile Image API: GET https://udbconnect.com/storage/profile_images/...',
    );
    print('==========================================');

    print(
      '👀 [SURVEY ANALYSIS SCREEN] Watching surveyAnalysisWithUsersProvider...',
    );
    final surveyAnalysisWithUsersAsync = ref.watch(
      SurveyAnalysisService.surveyAnalysisWithUsersProvider,
    );

    print('👀 [SURVEY ANALYSIS SCREEN] Watching profileProvider...');
    final userProfileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 65,
        title: Text(
          l10n.translate('survey_analysis_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadNotificationsCountProvider);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      context.goNamed(AppRouteNames.managerNotifications);
                    },
                  ),
                  unreadAsync.when(
                    data: (count) => count > 0
                        ? Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
          userProfileAsync.when(
            data: (user) {
              print(
                '✅ [SURVEY ANALYSIS SCREEN] User profile data loaded: ${user.name} (${user.role})',
              );
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    ApiUrls.getProfileImageUrl(user.profileImage),
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    print(
                      '⚠️ [SURVEY ANALYSIS SCREEN] Profile image failed to load: $exception',
                    );
                  },
                  child: user.profileImage == null || user.profileImage!.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
            loading: () {
              print(
                '⏳ [SURVEY ANALYSIS SCREEN] User profile data is loading...',
              );
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
            error: (error, stack) {
              print(
                '❌ [SURVEY ANALYSIS SCREEN] User profile data failed to load: $error',
              );
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: surveyAnalysisWithUsersAsync.when(
        data: (surveyAnalysisWithUsers) {
          print(
            '✅ [SURVEY ANALYSIS SCREEN] Survey analysis with users data loaded successfully',
          );
          print(
            '📊 [SURVEY ANALYSIS SCREEN] Found ${surveyAnalysisWithUsers.surveyAnalysis.data.length} surveys and ${surveyAnalysisWithUsers.totalUsersInBranch} total users',
          );
          return _buildContent(context, l10n, surveyAnalysisWithUsers);
        },
        loading: () {
          print(
            '⏳ [SURVEY ANALYSIS SCREEN] Survey analysis with users data is loading...',
          );
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
          );
        },
        error: (error, stack) {
          print(
            '❌ [SURVEY ANALYSIS SCREEN] Survey analysis with users data failed to load: $error',
          );
          return _buildErrorState(context, l10n, error.toString());
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    SurveyAnalysisWithUsers surveyAnalysisWithUsers,
  ) {
    final surveyAnalysis = surveyAnalysisWithUsers.surveyAnalysis;

    // TODO: In a real implementation, you would fetch manager user IDs from an API
    // For now, we'll use an empty list. You can add manager user IDs here as needed.
    // Based on your API response, managers are: ID 40 (zainab) and ID 53 (Ali Nawab)
    final managerUserIds = <int>[40, 53]; // Manager user IDs to exclude

    final analytics = SurveyAnalytics.fromSurveys(
      surveyAnalysis.data,
      excludeUserIds: managerUserIds,
    );
    final recentSurveys = surveyAnalysisWithUsers.surveysWithCompletion
        .take(3)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary badges
          _buildSummaryBadges(
            l10n,
            analytics,
            surveyAnalysisWithUsers.totalUsersInBranch,
          ),

          const SizedBox(height: 40),

          // Recent Surveys section
          _buildRecentSurveysSection(
            context,
            l10n,
            recentSurveys,
            managerUserIds,
          ),

          const SizedBox(height: 24),

          // Analytics section
          _buildAnalyticsSection(l10n, analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryBadges(
    AppLocalizations l10n,
    SurveyAnalytics analytics,
    int totalUsersInBranch,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryBadge(
            count: analytics.totalResponses,
            label: l10n.translate('survey_analysis_total_responses'),
            backgroundColor: const Color(0xFF6B8E23),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryBadge(
            count: analytics.activeSurveys,
            label: l10n.translate('survey_analysis_active_surveys'),
            backgroundColor: const Color(0xFF1E40AF),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBadge({
    required int count,
    required String label,
    required Color backgroundColor,
    bool showPercentage = false,
    int? totalUsers,
  }) {
    return Container(
      width: 171,
      height: 84,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            showPercentage && totalUsers != null && totalUsers > 0
                ? '${((count / totalUsers) * 100).toInt()}%'
                : count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8FBC8F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSurveysSection(
    BuildContext context,
    AppLocalizations l10n,
    List<SurveyAnalysisDataWithCompletion> surveys,
    List<int> managerUserIds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.translate('survey_analysis_recent_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRouteNames.allSurveys);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.translate('common_view_all'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7C32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...surveys.asMap().entries.map((entry) {
          final index = entry.key;
          final survey = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < surveys.length - 1 ? 16 : 0,
            ),
            child: _buildSurveyCard(l10n, survey, index, managerUserIds),
          );
        }).toList(),
      ],
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

          // Status row commented out per request (e.g., Active . 4 days left)
          // Row(
          //   children: [
          //     Text(
          //       survey.statusText,
          //       style: const TextStyle(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w400,
          //         color: Color(0xFF6B7280),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(
    AppLocalizations l10n,
    SurveyAnalytics analytics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('survey_analysis_analytics_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('survey_analysis_responses_over_time'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: _calculateYAxisInterval(
                            analytics.monthlyData,
                          ),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < analytics.monthlyData.length) {
                              return Text(
                                analytics.monthlyData[index].month,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: analytics.monthlyData.asMap().entries.map((
                          entry,
                        ) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.responses.toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFF6B8E23),
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF6B8E23),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF6B8E23).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            l10n.translate('survey_analysis_error_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Refresh data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E23),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.translate('retry')),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate Y-axis interval based on data
  double _calculateYAxisInterval(List<SurveyDataPoint> monthlyData) {
    if (monthlyData.isEmpty) return 1.0;

    final maxResponses = monthlyData
        .map((e) => e.responses)
        .reduce((a, b) => a > b ? a : b);

    if (maxResponses == 0) return 1.0;
    if (maxResponses <= 5) return 1.0;
    if (maxResponses <= 10) return 2.0;
    if (maxResponses <= 20) return 5.0;
    if (maxResponses <= 50) return 10.0;
    if (maxResponses <= 100) return 20.0;
    return 50.0;
  }
}
