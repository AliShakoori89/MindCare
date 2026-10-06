import '../Entities/user.dart';
import '../Repositories/user_repository.dart';

class CreateUser {
  final UserRepository _repository;

  CreateUser(this._repository);

  Future<void> call(User user) {
    return _repository.createUser(user);
  }
}