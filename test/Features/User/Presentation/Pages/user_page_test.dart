import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import 'package:mind_care/Features/User/Domain/UseCases/create_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/delete_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_all_users.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_user_by_id.dart';
import 'package:mind_care/Features/User/Domain/UseCases/update_user.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_bloc.dart';
import 'package:mind_care/Features/User/Presentation/Pages/user_page.dart';

class FakeUserRepository implements UserRepository {
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

class PendingUserRepository implements UserRepository {
  final Completer<void> createUserCompleter = Completer<void>();

  @override
  Future<void> createUser(User user) {
    return createUserCompleter.future;
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

UserBloc createTestBloc(UserRepository repository) {
  return UserBloc(
    CreateUser(repository),
    GetUserById(repository),
    GetAllUsers(repository),
    UpdateUser(repository),
    DeleteUser(repository),
  );
}

void main() {
  testWidgets('shows loading while creating user', (tester) async {
    final repository = PendingUserRepository();

    final bloc = createTestBloc(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const UserView(),
        ),
      ),
    );

    expect(
      find.text('Create User'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Create User'),
    );

    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    expect(
      find.text('Create User'),
      findsNothing,
    );

    repository.createUserCompleter.complete();

    await tester.pumpAndSettle();

    expect(
      find.textContaining('User created:'),
      findsOneWidget,
    );
  });

  testWidgets('shows Create User button initially', (tester) async {
    final bloc = createTestBloc(
      FakeUserRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const UserView(),
        ),
      ),
    );

    expect(
      find.text('Create User'),
      findsOneWidget,
    );
  });

  testWidgets('creates user when Create User button is tapped', (tester) async {
    final bloc = createTestBloc(
      FakeUserRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const UserView(),
        ),
      ),
    );

    expect(
      find.text('Create User'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Create User'),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining('User created:'),
      findsOneWidget,
    );
  });
}