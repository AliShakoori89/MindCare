import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_user_by_id.dart';

class FakeUserRepository implements UserRepository {
  User? user;

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async {
    if (user?.id == id) {
      return user;
    }

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
  test('returns user when user exists', () async {
    final repository = FakeUserRepository();

    final expectedUser = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    repository.user = expectedUser;

    final getUserById = GetUserById(repository);

    final result = await getUserById('user-1');

    expect(result, isNotNull);
    expect(result!.id, 'user-1');
    expect(result.createdAt, expectedUser.createdAt);
    expect(result.updatedAt, expectedUser.updatedAt);
  });

  test('returns null when user does not exist', () async {
    final repository = FakeUserRepository();

    final getUserById = GetUserById(repository);

    final result = await getUserById('unknown-user');

    expect(result, isNull);
  });
}
