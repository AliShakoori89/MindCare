
import '../../Domain/Entities/auth_session.dart';
import '../../Domain/Failures/auth_exception.dart';
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
  Future<void> sendOtp({required String email}) async {
    try {
      await remoteDataSource.sendOtp(email: email);
    } on AuthApiException catch (error) {
      throw _mapException(error);
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final session = await remoteDataSource.verifyOtp(
        email: email,
        code: code,
      );

      await localDataSource.saveSession(session);
      return session;
    } on AuthApiException catch (error) {
      throw _mapException(error);
    }
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

      throw _mapException(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final savedSession = await localDataSource.getSession();

      if (savedSession != null) {
        try {
          await remoteDataSource.logout(
            accessToken: savedSession.accessToken,
          );
        } on AuthApiException {
          // Local logout must succeed even if server logout fails.
        }
      }
    } finally {
      await localDataSource.clearSession();
    }
  }

  AuthException _mapException(AuthApiException error) {
    return AuthException(
      error.message,
      statusCode: error.statusCode,
    );
  }
}
