import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:udb_association/src/features/auth/provider/auth_tab_provider.dart';
import 'package:udb_association/src/features/auth/screens/login/login_screen.dart';
import 'package:udb_association/src/features/auth/screens/signup/signup_screen.dart';
import 'package:udb_association/src/features/auth/widgets/auth_header.dart';
import 'package:udb_association/src/features/auth/widgets/auth_tabs.dart';

class AuthScreen extends ConsumerWidget {
  final int initialTabIndex; // 0 login, 1 register
  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int tabIndex = ref.watch(authTabIndexProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AuthHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    AuthTabs(
                      current: tabIndex,
                      onChange: (i) =>
                          ref.read(authTabIndexProvider.notifier).state = i,
                    ),
                    const SizedBox(height: 24),
                    if (tabIndex == 0)
                      const LoginScreen()
                    else
                      const SignupScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
