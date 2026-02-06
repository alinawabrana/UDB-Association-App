import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/widgets/primary_button.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/provider/login_form_provider.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/validators/form_validators.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

import '../provider/auth_providers.dart';
import 'package:udb_association/src/common/storage/auth_prefs_storage.dart';
import 'package:udb_association/src/features/shop/providers/order_provider.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key, required this.state, required this.controller});

  final LoginFormState state;
  final LoginFormController controller;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _shouldAttemptLogin = false;
  bool _isPrefillLoaded = false;

  @override
  void initState() {
    super.initState();
    // Reset login state when form is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(loginProvider);
      if (!mounted) {
        return;
      }
      setState(() {
        _shouldAttemptLogin = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset login state when dependencies change (e.g., when navigating to login screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_shouldAttemptLogin) {
        ref.invalidate(loginProvider);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigateAfterLogin() {
    // Wait a bit for the profile to load, then navigate based on role
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) {
        return;
      }
      final profileAsync = ref.read(profileProvider);
      profileAsync.when(
        data: (user) {
          print('🚀 Login form navigation - User role: ${user.role}');
          context.goNamed(AppRouteNames.appImages);
        },
        loading: () {
          print('⏳ Login form - Profile still loading, retrying...');
          // Retry after a longer delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) {
              return;
            }
            _navigateAfterLogin();
          });
        },
        error: (error, stack) {
          print('❌ Login form - Profile error: $error, defaulting to home');
          context.goNamed(AppRouteNames.appImages);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_isPrefillLoaded) {
      _isPrefillLoaded = true;
      // Load remembered credentials once
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        final remembered = await const AuthPrefsStorage().readRemembered();
        if (!mounted) {
          return;
        }
        if (remembered.remember) {
          emailController.text = remembered.email ?? '';
          passwordController.text = remembered.password ?? '';
          widget.controller.setRememberMe(true);
          setState(() {});
        }
      });
    }
    // Only watch loginProvider when user has clicked login button
    final loginState = _shouldAttemptLogin
        ? ref.watch(
            loginProvider((emailController.text, passwordController.text)),
          )
        : const AsyncValue<String?>.data(null);

    const titleColor = Color(0xFF374151);
    final titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: titleColor,
    );
    return Form(
      key: loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('email_address'), style: titleStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: l10n.translate('email_hint'),
              prefixIcon: const Icon(Icons.mail),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => AFormValidators.validateEmail(value, l10n),
          ),
          const SizedBox(height: 16),
          Text(l10n.translate('password'), style: titleStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: widget.state.isPasswordObscured,
            decoration: InputDecoration(
              hintText: l10n.translate('password_hint'),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: widget.controller.togglePasswordVisibility,
                icon: Icon(
                  widget.state.isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) => AFormValidators.validatePassword(value, l10n),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Checkbox(
                value: widget.state.rememberMe,
                onChanged: (v) => widget.controller.setRememberMe(v ?? false),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                l10n.translate('remember_me'),
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.goNamed(AppRouteNames.forgetPassword),
                child: Text(
                  l10n.translate('forgot_password'),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.translate('sign_in'),
            leading: Row(
              children: [
                loginState.isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                SvgPicture.asset(
                  'assets/icons/login_icon.svg',
                  width: 16,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFFFFFF),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6B7C32).withOpacity(0.9),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Color(0xFF6B7C32), Color(0xFF8FA055)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000), // #0000001A → black with 10% opacity
                offset: Offset(0, 10), // x=0, y=10
                blurRadius: 15, // blur
                spreadRadius: 0, // spread
              ),
              BoxShadow(
                color: Color(0x1A000000), // same semi-transparent black
                offset: Offset(0, 4), // x=0, y=4
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
            foregroundColor: Colors.white,
            onPressed: () {
              if (loginFormKey.currentState!.validate()) {
                // Set flag to start watching the login provider
                setState(() {
                  _shouldAttemptLogin = true;
                });
                // Trigger the login process
                ref.invalidate(loginProvider);
                ref.read(
                  loginProvider((
                    emailController.text,
                    passwordController.text,
                  )),
                );
              }
            },
          ),
          loginState.when(
            data: (token) {
              if (token != null) {
                // Save or clear remember-me credentials based on checkbox
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!mounted) {
                    return;
                  }
                  await const AuthPrefsStorage().saveRememberedCredentials(
                    remember: widget.state.rememberMe,
                    email: widget.state.rememberMe
                        ? emailController.text
                        : null,
                    password: widget.state.rememberMe
                        ? passwordController.text
                        : null,
                  );

                  // Invalidate all user-related providers to fetch fresh data
                  if (!mounted) {
                    return;
                  }
                  ref.invalidate(profileProvider);
                  ref.invalidate(ordersProvider);
                  ref.invalidate(cartItemsProvider);
                  ref.invalidate(cartCountProvider);

                  // Force navigation after successful login
                  if (!mounted) {
                    return;
                  }
                  _navigateAfterLogin();
                });
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                SnackbarUtils.showError(context, message: err.cleanMessage);
              });
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
