import '../Entities/user.dart';
import '../Repositories/user_repository.dart';

class GetUserById {
  final UserRepository _repository;

  GetUserById(this._repository);

  Future<User?> call(String id) {
    return _repository.getUserById(id);
  }
}