import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/widgets/primary_button.dart';
import 'package:udb_association/src/features/auth/widgets/auth_header.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthHeader(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0x1A2563EB),
                      child: Image.asset(
                        'assets/icons/key_icon.png',
                        width: 24,
                        height: 24,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    SizedBox(height: 16),

                    Column(
                      children: [
                        Text(
                          'Forget Password?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No worries! Enter your email address and we'll send you a reset link.",
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your Email',
                            prefixIcon: Icon(Icons.mail),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    PrimaryButton(
                      label: 'Send Reset Link',
                      backgroundColor: Color(0xFF3B82F6),
                      icon: Icons.send,
                      foregroundColor: Colors.white,
                      onPressed: () {},
                    ),

                    SizedBox(height: 32),

                    TextButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF6B7A2B),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 16),
                          Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      height: 174,
                      width: double.infinity,
                      color: Color(0xFFF9FAFB),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 12),

                          Row(
                            spacing: 12,
                            children: [
                              NeedHelpCard(
                                icon: Icons.call,
                                label: 'Call Support',
                              ),
                              NeedHelpCard(
                                icon: Iconsax.message_21,
                                label: 'Live Chat',
                                iconColor: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/shield_icon.png',
                          width: 14,
                          height: 14,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Your data is secure and encrypted',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeedHelpCard extends StatelessWidget {
  const NeedHelpCard({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Color(0xFF6B7A2B)),

            SizedBox(height: 12),

            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
