import 'package:flutter/material.dart';

class AuthTabButton extends StatelessWidget {
  final bool selected;
  final String label;
  final Widget icon;
  final Color selectedText;
  final Color selectedBg;
  final VoidCallback onTap;

  const AuthTabButton({
    super.key,
    required this.selected,
    required this.label,
    required this.icon,
    required this.selectedText,
    required this.selectedBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? selectedText : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
