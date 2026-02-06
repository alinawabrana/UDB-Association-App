import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  final bool isPasswordObscured;
  final bool rememberMe;
  const LoginFormState({
    this.isPasswordObscured = true,
    this.rememberMe = false,
  });

  LoginFormState copyWith({bool? isPasswordObscured, bool? rememberMe}) =>
      LoginFormState(
        isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
        rememberMe: rememberMe ?? this.rememberMe,
      );
}

final loginFormProvider =
    StateNotifierProvider<LoginFormController, LoginFormState>((ref) {
      return LoginFormController();
    });

class LoginFormController extends StateNotifier<LoginFormState> {
  LoginFormController() : super(const LoginFormState());

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordObscured: !state.isPasswordObscured);
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }
}
