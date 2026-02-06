import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/features/surveys/providers/survey_providers.dart';
import 'package:udb_association/src/features/surveys/widgets/survey_card.dart';
import 'package:udb_association/src/features/surveys/widgets/survey_category_chips.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class SurveysScreen extends ConsumerStatefulWidget {
  const SurveysScreen({super.key});

  @override
  ConsumerState<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends ConsumerState<SurveysScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Invalidate providers to trigger refresh
      ref.invalidate(surveysProvider);
      ref.invalidate(userSurveyResponsesProvider);

      // Wait for the providers to refresh
      await ref.read(surveysProvider.future);
      await ref.read(userSurveyResponsesProvider.future);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSurveysAsync = ref.watch(filteredSurveysProvider);
    final selectedCategory = ref.watch(selectedSurveyCategoryProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('surveys'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _handleRefresh,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: l10n.translate('surveys_refresh_tooltip'),
                ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            color: const Color(0xFF6B7C32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SurveyCategoryChips(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  ref.read(selectedSurveyCategoryProvider.notifier).state =
                      category;
                },
              ),
            ),
          ),

          // Surveys list
          Expanded(
            child: filteredSurveysAsync.when(
              data: (surveys) {
                if (surveys.isEmpty) {
                  return _buildEmptyState(l10n, selectedCategory);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surveys.length,
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurveyCard(
                        survey: survey,
                        onTap: () {
                          // Check if user has already submitted this survey
                          final submissionStatus = ref.read(
                            userSurveySubmissionProvider(survey.id),
                          );
                          submissionStatus.when(
                            data: (hasSubmitted) {
                              if (hasSubmitted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.translate(
                                        'surveys_already_completed',
                                      ),
                                    ),
                                    backgroundColor:
                                        const Color(0xFF10B981),
                                  ),
                                );
                              } else {
                                context.pushNamed('survey_form', extra: survey);
                              }
                            },
                            loading: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.translate(
                                      'surveys_checking_status',
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF6B7C32),
                                ),
                              );
                            },
                            error: (error, stack) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.translate(
                                      'surveys_status_error',
                                      params: {'error': error.toString()},
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                              context.pushNamed('survey_form', extra: survey);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B7C32)),
              ),
              error: (error, stack) =>
                  _buildErrorState(l10n, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, SurveyCategory category) {
    String message;
    String subtitle;
    IconData icon;

    switch (category) {
      case SurveyCategory.completed:
        message = l10n.translate('surveys_empty_completed_title');
        subtitle =
            l10n.translate('surveys_empty_completed_subtitle');
        icon = Icons.check_circle_outline;
        break;
      case SurveyCategory.uncompleted:
        message = l10n.translate('surveys_empty_pending_title');
        subtitle = l10n.translate('surveys_empty_pending_subtitle');
        icon = Icons.task_alt;
        break;
      case SurveyCategory.all:
        message = l10n.translate('surveys_empty_all_title');
        subtitle =
            l10n.translate('surveys_empty_all_subtitle');
        icon = Icons.quiz_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            l10n.translate('surveys_error_title'),
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
              // Refresh surveys
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7C32),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.translate('surveys_retry')),
          ),
        ],
      ),
    );
  }
}
