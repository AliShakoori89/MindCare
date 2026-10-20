import '../Entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<void> sendOtp({
    required String email,
  });

  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
  });

  Future<AuthSession?> getCurrentSession();

  Future<void> logout();
}