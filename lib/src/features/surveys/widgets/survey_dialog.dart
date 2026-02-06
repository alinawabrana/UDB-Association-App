import 'package:flutter/material.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class SurveyDialog extends StatefulWidget {
  final Survey survey;
  final VoidCallback? onSkip;
  final Function(Map<String, dynamic>) onSubmit;

  const SurveyDialog({
    super.key,
    required this.survey,
    this.onSkip,
    required this.onSubmit,
  });

  @override
  State<SurveyDialog> createState() => _SurveyDialogState();
}

class _SurveyDialogState extends State<SurveyDialog> {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize answers and controllers for all questions
    for (final question in widget.survey.questions) {
      _answers[question.question] = '';
      if (question.type == 'text') {
        _textControllers[question.question] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.survey.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == widget.survey.questions.length - 1;
    final l10n = context.l10n;

    // Update text controller when question changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentQuestion.type == 'text' &&
          _textControllers.containsKey(currentQuestion.question)) {
        final controller = _textControllers[currentQuestion.question]!;
        final savedAnswer = _answers[currentQuestion.question] ?? '';
        if (controller.text != savedAnswer) {
          controller.text = savedAnswer;
        }
      }
    });

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(21),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            _buildHeader(l10n),
            const SizedBox(height: 16),

            // Question content
            _buildQuestionContent(l10n, currentQuestion),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(l10n, isLastQuestion),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(
              0xFF8FA653,
            ).withValues(alpha: 0.2), // 20% #8FA653
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.help_outline,
            color: Color(0xFF6B7C32), // #6B7C32
            size: 17.5,
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          l10n.translate('surveys_dialog_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827), // #111827
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(
    AppLocalizations l10n,
    SurveyQuestion question,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF374151), // #374151
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Answer input based on question type
        if (question.type == 'text')
          _buildTextInput(l10n, question)
        else if (question.type == 'multiple_choice')
          _buildMultipleChoiceInput(l10n, question),
      ],
    );
  }

  Widget _buildTextInput(
    AppLocalizations l10n,
    SurveyQuestion question,
  ) {
    final controller = _textControllers[question.question]!;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: l10n.translate('surveys_dialog_hint'),
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF374151),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6B7C32)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF374151),
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _answers[question.question] = value;
        });
      },
    );
  }

  Widget _buildMultipleChoiceInput(
    AppLocalizations l10n,
    SurveyQuestion question,
  ) {
    final options = _getMcqOptions(l10n, question);

    return Column(
      children: options.map((option) {
        final isSelected = _answers[question.question] == option;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[question.question] = option;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6B7C32)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6B7C32)
                            : const Color(0xFFD1D5DB),
                        width: 1,
                      ),
                    ),
                    child: isSelected
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF6B7C32),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Option text
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _getMcqOptions(
    AppLocalizations l10n,
    SurveyQuestion question,
  ) {
    final incomingOptions = question.options;
    if (incomingOptions != null && incomingOptions.isNotEmpty) {
      return incomingOptions;
    }

    // Default options for different types of questions
    if (question.question.toLowerCase().contains('satisfied') ||
        question.question.toLowerCase().contains('satisfaction')) {
      return [
        l10n.translate('surveys_option_yes_very_satisfied'),
        l10n.translate('surveys_option_needs_improvement'),
      ];
    } else if (question.question.toLowerCase().contains('recommend') ||
        question.question.toLowerCase().contains('recommendation')) {
      return [
        l10n.translate('surveys_option_yes_definitely'),
        l10n.translate('surveys_option_no_probably_not'),
      ];
    } else if (question.question.toLowerCase().contains('likely') ||
        question.question.toLowerCase().contains('probability')) {
      return [
        l10n.translate('surveys_option_very_likely'),
        l10n.translate('surveys_option_not_likely'),
      ];
    } else {
      // Generic options
      return [
        l10n.translate('surveys_option_yes'),
        l10n.translate('surveys_option_no'),
      ];
    }
  }

  Widget _buildActionButtons(
    AppLocalizations l10n,
    bool isLastQuestion,
  ) {
    return Row(
      children: [
        // Skip button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSkip?.call();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
            ),
            child: Text(
              l10n.translate('surveys_button_skip'),
              style: const TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Submit/Next button
        Expanded(
          child: ElevatedButton(
            onPressed: _canSubmit() ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7C32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              elevation: 0,
            ),
            child: Text(
              isLastQuestion
                  ? l10n.translate('surveys_button_submit')
                  : l10n.translate('surveys_button_next'),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  bool _canSubmit() {
    final currentQuestion = widget.survey.questions[_currentQuestionIndex];
    final answer = _answers[currentQuestion.question];
    return answer != null && answer.toString().trim().isNotEmpty;
  }

  void _handleSubmit() {
    // Update answers from current text controllers before moving to next question
    for (final question in widget.survey.questions) {
      if (question.type == 'text' &&
          _textControllers.containsKey(question.question)) {
        _answers[question.question] = _textControllers[question.question]!.text;
      }
    }

    if (_currentQuestionIndex < widget.survey.questions.length - 1) {
      // Move to next question
      setState(() {
        _currentQuestionIndex++;
      });

      // Clear the text field for the next question if it's a text question
      final nextQuestion = widget.survey.questions[_currentQuestionIndex];
      if (nextQuestion.type == 'text' &&
          _textControllers.containsKey(nextQuestion.question)) {
        _textControllers[nextQuestion.question]!.clear();
      }
    } else {
      // Submit all answers
      Navigator.of(context).pop();
      widget.onSubmit(_answers);
    }
  }
}
