class AuthResponse {
  final String token;
  final int userId;
  final String email;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['user']['id'],
      email: json['user']['email'],
    );
  }
}
