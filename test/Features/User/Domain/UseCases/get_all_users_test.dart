import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_all_users.dart';

class FakeUserRepository implements UserRepository {
  final List<User> users;

  FakeUserRepository(this.users);

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async {
    return null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    return users;
  }

  @override
  Future<void> updateUser(User user) async {}

  @override
  Future<void> deleteUser(String id) async {}
}

void main() {
  test('returns all users', () async {
    final users = [
      User(
        id: 'user-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      User(
        id: 'user-2',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      ),
    ];

    final repository = FakeUserRepository(users);
    final getAllUsers = GetAllUsers(repository);

    final result = await getAllUsers();

    expect(result, hasLength(2));
    expect(
      result.map((user) => user.id),
      containsAll([
        'user-1',
        'user-2',
      ]),
    );
  });

  test('returns empty list when there are no users', () async {
    final repository = FakeUserRepository([]);
    final getAllUsers = GetAllUsers(repository);

    final result = await getAllUsers();

    expect(result, isEmpty);
  });
}