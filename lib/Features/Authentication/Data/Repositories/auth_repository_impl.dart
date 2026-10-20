
import '../../Domain/Entities/auth_session.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../Data_Sources/auth_local_data_source.dart';
import '../Data_Sources/auth_remote_data_source.dart';
import '../Data_Sources/auth_remote_data_source_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> sendOtp({required String email}) {
    return remoteDataSource.sendOtp(email: email);
  }

  @override
  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
  }) async {
    final session = await remoteDataSource.verifyOtp(
      email: email,
      code: code,
    );

    await localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    final savedSession = await localDataSource.getSession();

    if (savedSession == null) {
      return null;
    }

    try {
      return await remoteDataSource.getCurrentSession(
        accessToken: savedSession.accessToken,
      );
    } on AuthApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await localDataSource.clearSession();
        return null;
      }

      // Network errors and server errors must not erase a valid
      // locally stored session.
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final savedSession = await localDataSource.getSession();

    try {
      if (savedSession != null) {
        await remoteDataSource.logout(
          accessToken: savedSession.accessToken,
        );
      }
    } finally {
      // Always remove the local session, even if the server is offline.
      await localDataSource.clearSession();
    }
  }
}
