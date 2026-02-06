import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: locale,
      delegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(bottom: false, child: _LoadingContent()),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 116),
          const _LogoBadge(),
          const SizedBox(height: 59),
          Text(
            l10n.translate('welcome_back'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 54),
          const _LoadingBar(),
          const SizedBox(height: 16),
          Text(
            l10n.translate('setting_up_interface'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.translate('setting_up_experience'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            l10n.translate('version_label'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 268,
        width: 268,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/icons/UDB_LOGO.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              minHeight: 6,
              value: value,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD503)),
              backgroundColor: Colors.black.withOpacity(0.2),
            );
          },
        ),
      ),
    );
  }
}
