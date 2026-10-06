import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/delete_user.dart';

class FakeUserRepository implements UserRepository {
  String? deletedUserId;

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async {
    return null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    return [];
  }

  @override
  Future<void> updateUser(User user) async {}

  @override
  Future<void> deleteUser(String id) async {
    deletedUserId = id;
  }
}

void main() {
  test('deletes user through repository', () async {
    final repository = FakeUserRepository();

    final deleteUser = DeleteUser(repository);

    await deleteUser('user-1');

    expect(repository.deletedUserId, 'user-1');
  });
}