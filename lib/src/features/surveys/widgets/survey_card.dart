import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/features/surveys/providers/survey_providers.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class SurveyCard extends ConsumerWidget {
  final Survey survey;
  final VoidCallback onTap;

  const SurveyCard({super.key, required this.survey, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionStatus = ref.watch(userSurveySubmissionProvider(survey.id));
    final isCompleted = submissionStatus.when(
      data: (hasSubmitted) => hasSubmitted,
      loading: () => false,
      error: (_, __) => false,
    );

    final isActive = survey.status == 'active';
    final questionCount = survey.questions.length;
    final l10n = context.l10n;
    final questionLabel = questionCount == 1
        ? l10n.translate(
            'surveys_question_single',
            params: {'count': questionCount.toString()},
          )
        : l10n.translate(
            'surveys_question_plural',
            params: {'count': questionCount.toString()},
          );
    final statusLabel = isCompleted
        ? l10n.translate('surveys_status_completed')
        : l10n.translate('surveys_status_pending');
    final buttonLabel = _getButtonText(l10n, isCompleted, isActive);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status and question count
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFF6B7C32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.quiz_outlined,
                          size: 14,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7C32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7C32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Question count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                    questionLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Survey title
              Text(
                survey.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Survey description
              Text(
                survey.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer with branch info and action
              Row(
                children: [
                  // Branch info
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            survey.branch.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getButtonColor(
                        isCompleted,
                        isActive,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                    buttonLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getButtonColor(isCompleted, isActive),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(
    AppLocalizations l10n,
    bool isCompleted,
    bool isActive,
  ) {
    if (!isActive) {
      return l10n.translate('surveys_status_expired');
    } else if (isCompleted) {
      return l10n.translate('surveys_status_completed');
    } else {
      return l10n.translate('surveys_status_start');
    }
  }

  Color _getButtonColor(bool isCompleted, bool isActive) {
    if (!isActive) {
      return const Color(0xFF6B7280); // Gray for expired
    } else if (isCompleted) {
      return const Color(0xFF10B981); // Green for completed
    } else {
      return const Color(0xFF6B7C32); // Default green for start
    }
  }
}
