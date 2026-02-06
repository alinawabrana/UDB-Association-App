import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:udb_association/src/features/auth/provider/login_form_provider.dart';
import 'package:udb_association/src/features/auth/widgets/login_form.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginFormState state = ref.watch(loginFormProvider);
    final controller = ref.read(loginFormProvider.notifier);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LoginForm(state: state, controller: controller),
        const SizedBox(height: 24),
        // GoogleFacebookLogin(),
        // const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.translate('copyright_notice'),
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
