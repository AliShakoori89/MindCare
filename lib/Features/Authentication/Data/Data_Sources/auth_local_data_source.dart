
import '../../Domain/Entities/auth_session.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveSession(AuthSession session);

  Future<AuthSession?> getSession();

  Future<void> clearSession();
}
