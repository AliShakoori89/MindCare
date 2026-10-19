class AuthSession {
  final String userId;
  final String email;
  final String accessToken;
  final String? refreshToken;

  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    this.refreshToken,
  });
}