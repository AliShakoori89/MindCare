import '../Entities/user.dart';
import '../Repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository _repository;

  GetAllUsers(this._repository);

  Future<List<User>> call() {
    return _repository.getAllUsers();
  }
}
