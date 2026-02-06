import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/utils/constants/colors.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AColors.primaryLinearGradient),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/handshake_icon.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('udb_association'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.translate('auth_tagline'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
