
import '../Entities/auth_session.dart';
import '../Repositories/auth_repository.dart';

class GetCurrentSession {
  final AuthRepository repository;

  GetCurrentSession(this.repository);

  Future<AuthSession?> call() {
    return repository.getCurrentSession();
  }
}
