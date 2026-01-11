import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../models/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  // LOGIN
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.login(email, password);
      await TokenStorage.saveToken(result.token);

      state = state.copyWith(isLoggedIn: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.signup(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // FORGOT PASSWORD (SEND OTP)
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // RESET PASSWORD (OTP + NEW PASSWORD)
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ======================
  // CHECK LOGIN STATUS
  // ======================
  Future<void> checkLoginStatus() async {
    final token = await TokenStorage.getToken();
    state = state.copyWith(
      isLoggedIn: token != null,
      isLoading: false,
      error: null,
    );
  }

  // ======================
  // LOGOUT
  // ======================
  Future<void> logout() async {
    await TokenStorage.deleteToken();
    state = AuthState.initial();
  }
}
