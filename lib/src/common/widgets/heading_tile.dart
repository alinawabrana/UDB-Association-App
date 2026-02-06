import 'package:flutter/material.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class HeadingTile extends StatelessWidget {
  const HeadingTile({
    super.key,
    required this.icon,
    required this.headingTitle,
    this.isViewAll = false,
    this.onViewAllTap,
  });

  final IconData icon;
  final String headingTitle;
  final bool isViewAll;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, color: Color(0xFF6B7B47), size: 18),
        Text(
          headingTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        Spacer(),
        if (isViewAll == true)
          GestureDetector(
            onTap: onViewAllTap,
            child: Text(
              context.l10n.translate('common_view_all'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
      ],
    );
  }
}
