import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/update_user.dart';

class FakeUserRepository implements UserRepository {
  User? updatedUser;

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
  Future<void> updateUser(User user) async {
    updatedUser = user;
  }

  @override
  Future<void> deleteUser(String id) async {}
}

void main() {
  test('updates user through repository', () async {
    final repository = FakeUserRepository();

    final user = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    final updateUser = UpdateUser(repository);

    await updateUser(user);

    expect(repository.updatedUser, isNotNull);
    expect(repository.updatedUser!.id, user.id);
    expect(
      repository.updatedUser!.updatedAt,
      user.updatedAt,
    );
  });
}