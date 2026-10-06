import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Features/User/Data/Data_Sources/user_local_data_source_impl.dart';
import 'package:mind_care/Features/User/Data/Repositories/user_repository_impl.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart'
as domain;

void main() {
  late AppDatabase database;
  late UserRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    final usersDao = UsersDao(database);

    final localDataSource = UserLocalDataSourceImpl(usersDao);

    repository = UserRepositoryImpl(localDataSource);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and gets user', () async {
    final user = domain.User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    await repository.createUser(user);

    final result = await repository.getUserById(user.id);

    expect(result, isNotNull);
    expect(result!.id, user.id);
    expect(result.createdAt, user.createdAt);
    expect(result.updatedAt, user.updatedAt);
  });

  test('gets all users', () async {
    final user1 = domain.User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final user2 = domain.User(
      id: 'user-2',
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    );

    await repository.createUser(user1);
    await repository.createUser(user2);

    final users = await repository.getAllUsers();

    expect(users, hasLength(2));
    expect(
      users.map((user) => user.id),
      containsAll([
        'user-1',
        'user-2',
      ]),
    );
  });

  test('updates user', () async {
    final createdAt = DateTime(2026, 1, 1);
    final updatedAt = DateTime(2026, 1, 2);

    final user = domain.User(
      id: 'user-1',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await repository.createUser(user);

    final updatedUser = domain.User(
      id: user.id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    await repository.updateUser(updatedUser);

    final result = await repository.getUserById(user.id);

    expect(result, isNotNull);
    expect(result!.updatedAt, updatedAt);
  });

  test('deletes user', () async {
    final user = domain.User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    await repository.createUser(user);

    await repository.deleteUser(user.id);

    final result = await repository.getUserById(user.id);

    expect(result, isNull);
  });
}