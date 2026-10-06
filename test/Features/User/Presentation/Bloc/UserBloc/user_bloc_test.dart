import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/create_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/delete_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_all_users.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_user_by_id.dart';
import 'package:mind_care/Features/User/Domain/UseCases/update_user.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_bloc.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_event.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_state.dart';

class FailingUserRepository implements UserRepository {
  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async {
    throw Exception('Failed to get user');
  }

  @override
  Future<List<User>> getAllUsers() async {
    throw Exception('Failed to get users');
  }

  @override
  Future<void> updateUser(User user) async {
    throw Exception('Failed to update user');
  }

  @override
  Future<void> deleteUser(String id) async {
    throw Exception('Failed to delete user');
  }
}

class NotFoundUserRepository implements UserRepository {
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
  Future<void> deleteUser(String id) async {}
}

class FakeUserRepository implements UserRepository {
  final User user;

  FakeUserRepository(this.user);

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async {
    return user;
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

class UsersRepository implements UserRepository {
  final List<User> users;

  UsersRepository(this.users);

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async => null;

  @override
  Future<List<User>> getAllUsers() async {
    return users;
  }

  @override
  Future<void> updateUser(User user) async {}

  @override
  Future<void> deleteUser(String id) async {}
}

class UpdateUserRepository implements UserRepository {
  User? updatedUser;

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async => null;

  @override
  Future<List<User>> getAllUsers() async => [];

  @override
  Future<void> updateUser(User user) async {
    updatedUser = user;
  }

  @override
  Future<void> deleteUser(String id) async {}
}

class DeleteUserRepository implements UserRepository {
  String? deletedUserId;

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<User?> getUserById(String id) async => null;

  @override
  Future<List<User>> getAllUsers() async => [];

  @override
  Future<void> updateUser(User user) async {}

  @override
  Future<void> deleteUser(String id) async {
    deletedUserId = id;
  }
}

void main() {

  test('emits loading and error when deleting user fails', () async {
    final repository = FailingUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const DeleteUserEvent('user-1'),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);

    expect(
      states[0],
      isA<UserLoading>(),
    );

    expect(
      states[1],
      isA<UserError>(),
    );

    final errorState = states[1] as UserError;

    expect(
      errorState.message,
      'Exception: Failed to delete user',
    );

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and error when getting all users fails', () async {
    final repository = FailingUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const GetAllUsersEvent(),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);

    expect(
      states[0],
      isA<UserLoading>(),
    );

    expect(
      states[1],
      isA<UserError>(),
    );

    final errorState = states[1] as UserError;

    expect(
      errorState.message,
      'Exception: Failed to get users',
    );

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and error when getting user fails', () async {
    final repository = FailingUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const GetUserByIdEvent('user-1'),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);

    expect(
      states[0],
      isA<UserLoading>(),
    );

    expect(
      states[1],
      isA<UserError>(),
    );

    final errorState = states[1] as UserError;

    expect(
      errorState.message,
      'Exception: Failed to get user',
    );

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and error when updating user fails', () async {
    final repository = FailingUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    final user = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    bloc.add(
      UpdateUserEvent(user),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);

    expect(
      states[0],
      isA<UserLoading>(),
    );

    expect(
      states[1],
      isA<UserError>(),
    );

    final errorState = states[1] as UserError;

    expect(
      errorState.message,
      'Exception: Failed to update user',
    );

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and error when user is not found', () async {
    final repository = NotFoundUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const GetUserByIdEvent('unknown-user'),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states[0], isA<UserLoading>());
    expect(states[1], isA<UserError>());

    final errorState = states[1] as UserError;

    expect(
      errorState.message,
      'User not found',
    );

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and success when user is found', () async {
    final user = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final repository = FakeUserRepository(user);

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const GetUserByIdEvent('user-1'),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states[0], isA<UserLoading>());
    expect(states[1], isA<UserByIdSuccess>());

    final successState = states[1] as UserByIdSuccess;

    expect(successState.user.id, 'user-1');
    expect(successState.user, user);

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and success when users are found', () async {
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

    final repository = UsersRepository(users);

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const GetAllUsersEvent(),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states[0], isA<UserLoading>());
    expect(states[1], isA<UserListSuccess>());

    final successState = states[1] as UserListSuccess;

    expect(successState.users.length, 2);
    expect(successState.users, users);

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and success when user is updated', () async {
    final user = User(
      id: 'user-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    final repository = UpdateUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      UpdateUserEvent(user),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states[0], isA<UserLoading>());
    expect(states[1], isA<UserUpdateSuccess>());

    final successState = states[1] as UserUpdateSuccess;

    expect(successState.user, user);
    expect(repository.updatedUser, user);

    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and success when user is deleted', () async {
    const userId = 'user-1';

    final repository = DeleteUserRepository();

    final bloc = UserBloc(
      CreateUser(repository),
      GetUserById(repository),
      GetAllUsers(repository),
      UpdateUser(repository),
      DeleteUser(repository),
    );

    final states = <UserState>[];

    final subscription = bloc.stream.listen(states.add);

    bloc.add(
      const DeleteUserEvent(userId),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states[0], isA<UserLoading>());
    expect(states[1], isA<UserDeleteSuccess>());

    final successState = states[1] as UserDeleteSuccess;

    expect(successState.id, userId);
    expect(repository.deletedUserId, userId);

    await subscription.cancel();
    await bloc.close();
  });
}