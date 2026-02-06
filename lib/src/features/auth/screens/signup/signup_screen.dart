import 'package:flutter/material.dart';
import 'package:udb_association/src/features/auth/widgets/signup_form.dart';
import 'package:udb_association/src/features/auth/widgets/social_accounts_login.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Let\'s create your account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 24),
        SignupForm(),
        SizedBox(height: 24),
        // GoogleFacebookLogin(),
      ],
    );
  }
}
