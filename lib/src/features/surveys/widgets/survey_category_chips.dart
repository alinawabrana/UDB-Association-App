import 'package:flutter/material.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class SurveyCategoryChips extends StatelessWidget {
  final SurveyCategory selectedCategory;
  final ValueChanged<SurveyCategory> onCategorySelected;

  const SurveyCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SurveyCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          final label = _getCategoryLabel(l10n, category);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF6B7C32) : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryLabel(
    AppLocalizations l10n,
    SurveyCategory category,
  ) {
    switch (category) {
      case SurveyCategory.all:
        return l10n.translate('surveys_filter_all');
      case SurveyCategory.completed:
        return l10n.translate('surveys_filter_completed');
      case SurveyCategory.uncompleted:
        return l10n.translate('surveys_filter_uncompleted');
    }
  }
}
