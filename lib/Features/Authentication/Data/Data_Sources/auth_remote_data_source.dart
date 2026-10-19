import '../../Domain/Entities/auth_session.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> sendOtp({
    required String email,
  });

  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
  });

  Future<AuthSession> getCurrentSession({
    required String accessToken,
  });

  Future<void> logout({
    required String accessToken,
  });
}
