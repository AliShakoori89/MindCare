
import '../Repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository repository;

  SendOtp(this.repository);

  Future<void> call({required String email}) {
    return repository.sendOtp(email: email);
  }
}
