
import '../Entities/auth_session.dart';
import '../Repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<AuthSession> call({
    required String email,
    required String code,
  }) {
    return repository.verifyOtp(
      email: email,
      code: code,
    );
  }
}
