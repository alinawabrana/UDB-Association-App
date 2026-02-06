import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'auth_tab_button.dart';

class AuthTabs extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChange;

  const AuthTabs({super.key, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const Color selectedText = Color(0xFF6B7C32);
    const Color selectedBg = Colors.white;
    const Color containerBg = Color(0xFFF3F4F6);
    const Color border = Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: <Widget>[
          AuthTabButton(
            selected: current == 0,
            label: l10n.translate('login'),
            selectedText: selectedText,
            selectedBg: selectedBg,
            icon: SvgPicture.asset(
              'assets/icons/login_icon.svg',
              width: 16,
              height: 14,
              colorFilter: const ColorFilter.mode(
                selectedText,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => onChange(0),
          ),
          const SizedBox(width: 8),
          AuthTabButton(
            selected: current == 1,
            label: l10n.translate('register'),
            selectedText: selectedText,
            selectedBg: selectedBg,
            icon: const Icon(
              Icons.person_add_alt_1,
              size: 20,
              color: selectedText,
            ),
            onTap: () => onChange(1),
          ),
        ],
      ),
    );
  }
}
