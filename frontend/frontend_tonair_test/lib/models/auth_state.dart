class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isLoggedIn,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(isLoggedIn: false, isLoading: false, error: null);
  }

  AuthState copyWith({bool? isLoggedIn, bool? isLoading, String? error}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
