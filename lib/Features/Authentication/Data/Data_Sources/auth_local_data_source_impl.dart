
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../Domain/Entities/auth_session.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _accessTokenKey = 'auth_access_token';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveSession(AuthSession session) async {
    await storage.write(
      key: _userIdKey,
      value: session.userId,
    );
    await storage.write(
      key: _emailKey,
      value: session.email,
    );
    await storage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
  }

  @override
  Future<AuthSession?> getSession() async {
    final values = await Future.wait([
      storage.read(key: _userIdKey),
      storage.read(key: _emailKey),
      storage.read(key: _accessTokenKey),
    ]);

    final userId = values[0];
    final email = values[1];
    final accessToken = values[2];

    if (userId == null || email == null || accessToken == null) {
      return null;
    }

    if (userId.isEmpty || email.isEmpty || accessToken.isEmpty) {
      return null;
    }

    return AuthSession(
      userId: userId,
      email: email,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> clearSession() async {
    await storage.delete(key: _userIdKey);
    await storage.delete(key: _emailKey);
    await storage.delete(key: _accessTokenKey);
  }
}
