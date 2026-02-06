import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/auth/widgets/auth_social_button.dart';
import 'package:udb_association/src/features/auth/widgets/or_continue_with_divider.dart';
import 'package:udb_association/src/features/shop/providers/order_provider.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';

class GoogleFacebookLogin extends ConsumerStatefulWidget {
  const GoogleFacebookLogin({super.key});

  @override
  ConsumerState<GoogleFacebookLogin> createState() =>
      _GoogleFacebookLoginState();
}

class _GoogleFacebookLoginState extends ConsumerState<GoogleFacebookLogin> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrContinueWithDivider(),
        const SizedBox(height: 16),
        AuthSocialButton(
          label: _isLoading ? 'Signing in...' : 'Continue with Google',
          icon: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFDB4437),
                    ),
                  ),
                )
              : const Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Color(0xFFDB4437),
                ),
          onTap: _isLoading ? () {} : _handleGoogleSignIn,
        ),
        const SizedBox(height: 12),
        AuthSocialButton(
          label: 'Continue with Facebook',
          icon: const Icon(Icons.facebook, size: 22, color: Color(0xFF1877F2)),
          onTap: () {
            // TODO: Implement Facebook login
            SnackbarUtils.showInfo(
              context,
              message: 'Facebook login coming soon!',
            );
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Need help? ',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Contact Support',
                  style: TextStyle(
                    color: Color(0xFF6B7C32),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger Google Sign-In using the notifier and get the result directly
      final token = await ref
          .read(googleSignInNotifierProvider.notifier)
          .signIn();

      if (token != null) {
        // Update the auth token
        ref.read(authTokenProvider.notifier).state = token;

        // Invalidate all user-related providers to fetch fresh data
        ref.invalidate(profileProvider);
        ref.invalidate(ordersProvider);
        ref.invalidate(cartItemsProvider);
        ref.invalidate(cartCountProvider);

        // If we reach here, login was successful
        if (mounted) {
          SnackbarUtils.showSuccess(
            context,
            message: 'Google Sign-In successful!',
          );

          // Let the router redirect handle navigation automatically
          // The router will detect the token change and redirect to /home
        }
      } else {
        // User cancelled the sign-in, don't show error
        if (mounted) {
          SnackbarUtils.showWarning(
            context,
            message: 'Google Sign-In cancelled',
          );
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        // Check if it's a configuration error
        String errorMessage = e.toString();
        if (errorMessage.contains('canceled') ||
            errorMessage.contains('cancelled')) {
          SnackbarUtils.showWarning(
            context,
            message:
                'Google Sign-In is not properly configured. Please check the setup guide.',
          );
        } else {
          // Simple error handling - no special retry logic
          SnackbarUtils.showError(
            context,
            message: 'Google Sign-In failed: ${e.cleanMessage}',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
