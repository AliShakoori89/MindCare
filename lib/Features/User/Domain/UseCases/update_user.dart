import '../Entities/user.dart';
import '../Repositories/user_repository.dart';

class UpdateUser {
  final UserRepository _repository;

  UpdateUser(this._repository);

  Future<void> call(User user) {
    return _repository.updateUser(user);
  }
}