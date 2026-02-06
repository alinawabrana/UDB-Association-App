import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_localizations.dart';
import 'localization_providers.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final l10n = context.l10n;

    final bool isFrench = locale.languageCode == 'fr';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Make it responsive for small screens
        final minWidth = isSmallScreen ? 80.0 : 96.0;
        final optionWidth = isSmallScreen ? 40.0 : 48.0;
        final fontSize = isSmallScreen ? 11.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(minWidth: minWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: l10n.translate('language_french_short'),
            isSelected: isFrench,
            onTap: () => localeNotifier.setLocale(const Locale('fr')),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(24),
            ),
                width: optionWidth,
                fontSize: fontSize,
          ),
          _LanguageOption(
            label: l10n.translate('language_english_short'),
            isSelected: !isFrench,
            onTap: () => localeNotifier.setLocale(const Locale('en')),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(24),
            ),
                width: optionWidth,
                fontSize: fontSize,
          ),
        ],
      ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
    required this.width,
    required this.fontSize,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final double width;
  final double fontSize;

  static const _selectedColor = Color(0xFF1C47AD);
  static const _unselectedColor = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _selectedColor : Colors.transparent,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              letterSpacing: 0.6,
              color: isSelected ? Colors.white : _unselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}
