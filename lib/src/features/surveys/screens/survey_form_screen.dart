import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/features/surveys/providers/survey_providers.dart';
import 'package:udb_association/src/features/surveys/widgets/survey_dialog.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final Survey survey;

  const SurveyFormScreen({super.key, required this.survey});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Show the survey dialog immediately when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSurveyDialog();
    });
  }

  void _showSurveyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SurveyDialog(
        survey: widget.survey,
        onSkip: () {
          Navigator.of(context).pop(); // Close the survey form screen
        },
        onSubmit: _submitSurvey,
      ),
    );
  }

  void _submitSurvey(Map<String, dynamic> answers) async {
    final l10n = context.l10n;
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(surveySubmissionProvider.notifier)
          .submitSurvey(surveyId: widget.survey.id, answers: answers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n.translate('surveys_submit_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate(
                'surveys_submit_error',
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.survey.title),
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubmitting) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.translate('surveys_status_submitting'),
              ),
            ] else ...[
              const Icon(Icons.quiz, size: 64, color: Color(0xFF6B7C32)),
              const SizedBox(height: 16),
              Text(
                l10n.translate('surveys_loading_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.survey.title,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
