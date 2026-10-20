class AuthSession {
  final String userId;
  final String email;
  final String accessToken;

  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
  });
}