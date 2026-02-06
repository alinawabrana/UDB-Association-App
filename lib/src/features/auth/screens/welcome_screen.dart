import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/common/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

import '../provider/auth_tab_provider.dart';

// MVC: Model
class WelcomeModel {
  final String appName;
  final String subtitle;
  final String description;

  const WelcomeModel({
    this.appName = 'UDB',
    this.subtitle = 'Association Platform',
    this.description =
        'Connect, collaborate, and grow with your\ncommunity members',
  });
}

// MVC: Controller (Riverpod)
class WelcomeController extends StateNotifier<WelcomeModel> {
  WelcomeController() : super(const WelcomeModel());

  void onSignIn(BuildContext context) {
    context.goNamed(AppRouteNames.login);
  }

  void onCreateAccount(BuildContext context) {
    context.goNamed(AppRouteNames.signup);
  }

  void onContinueAsGuest(BuildContext context) {
    context.goNamed(AppRouteNames.guest);
  }
}

final welcomeControllerProvider =
    StateNotifierProvider<WelcomeController, WelcomeModel>((ref) {
      return WelcomeController();
    });

// MVC: View
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WelcomeModel model = ref.watch(welcomeControllerProvider);
    final WelcomeController controller = ref.read(
      welcomeControllerProvider.notifier,
    );
    final l10n = context.l10n;

    // Colors retained for reference to design palette
    // final Color darkGreen = const Color(0xFF4A5A22);
    // final Color lightGreen = const Color(0xFF6B7C32);
    final Color buttonBlue = const Color(0xFF2F64EA);
    final Color signInForeground = const Color(0xFF6B7C32);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF6B7C32), Color(0xFF4A5A22)],
            transform: GradientRotation(135 * 3.1415926535 / 180),
            stops: <double>[0.0, 0.7071],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 60),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/handshake_icon.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      l10n.translate(
                        'welcome_title',
                        params: {'appName': model.appName},
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('welcome_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('welcome_description'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      label: l10n.translate('sign_in'),
                      leading: SvgPicture.asset(
                        'assets/icons/login_icon.svg',
                        width: 16,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          signInForeground,
                          BlendMode.srcIn,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: signInForeground,
                      onPressed: () {
                        ref.read(authTabIndexProvider.notifier).state = 0;
                        controller.onSignIn(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: l10n.translate('create_account'),
                      icon: Icons.person_add_alt_1,
                      backgroundColor: buttonBlue,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        ref.read(authTabIndexProvider.notifier).state = 1;
                        controller.onCreateAccount(context);
                      },
                    ),
                    const SizedBox(height: 32),
                    // Text(
                    //   'OR',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w400,
                    //     color: Colors.white.withOpacity(0.5),
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    // TextButton(
                    //   onPressed: () => controller.onContinueAsGuest(context),
                    //   child: Text(
                    //     'Continue as Guest',
                    //     style: TextStyle(
                    //       color: Colors.white.withOpacity(0.8),
                    //       fontWeight: FontWeight.w400,
                    //       decoration: TextDecoration.underline,
                    //       decorationColor: Colors.white.withOpacity(0.8),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// PrimaryButton moved to common/widgets/primary_button.dart
