import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/create_user.dart';

class FakeUserRepository implements UserRepository {
  User? createdUser;

  @override
  Future<void> createUser(User user) async {
    createdUser = user;
  }

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
  Future<void> deleteUser(String id) async {}
}

void main() {
  test('creates user through repository', () async {
    final repository = FakeUserRepository();
    final createUser = CreateUser(repository);

    final user = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    await createUser(user);

    expect(repository.createdUser, isNotNull);
    expect(repository.createdUser!.id, user.id);
    expect(repository.createdUser!.createdAt, user.createdAt);
    expect(repository.createdUser!.updatedAt, user.updatedAt);
  });
}