import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_bloc.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_event.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_state.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Center(
            child: switch (state) {
              UserInitial() => ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();

                  final user = User(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    createdAt: now,
                    updatedAt: now,
                  );

                  context.read<UserBloc>().add(
                    CreateUserEvent(user),
                  );
                },
                child: const Text('Create User'),
              ),
              UserLoading() => const CircularProgressIndicator(),
              UserCreateSuccess(:final user) => Text(
                'User created: ${user.id}',
              ),
              UserByIdSuccess(:final user) => Text(
                'User found: ${user.id}',
              ),
              UserListSuccess(:final users) => Text(
                'Users found: ${users.length}',
              ),
              UserUpdateSuccess(:final user) => Text(
                'User updated: ${user.id}',
              ),
              UserDeleteSuccess(:final id) => Text(
                'User deleted: $id',
              ),
              UserError(:final message) => Text(
                'Error: $message',
              ),
            },
          );
        },
      ),
    );
  }
}