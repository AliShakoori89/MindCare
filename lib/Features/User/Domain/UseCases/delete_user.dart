import '../Repositories/user_repository.dart';

class DeleteUser {
  final UserRepository _repository;

  DeleteUser(this._repository);

  Future<void> call(String id) {
    return _repository.deleteUser(id);
  }
}