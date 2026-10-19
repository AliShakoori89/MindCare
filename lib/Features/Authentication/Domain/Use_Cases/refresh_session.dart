
import '../Entities/auth_session.dart';
import '../Repositories/auth_repository.dart';

class RefreshSession {
  final AuthRepository repository;

  RefreshSession(this.repository);

  Future<AuthSession> call() {
    return repository.refreshSession();
  }
}
