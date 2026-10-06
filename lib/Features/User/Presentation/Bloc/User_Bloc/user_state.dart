import 'package:mind_care/Features/User/Domain/Entities/user.dart';

sealed class UserState {
  const UserState();
}

final class UserInitial extends UserState {
  const UserInitial();
}

final class UserLoading extends UserState {
  const UserLoading();
}

final class UserCreateSuccess extends UserState {
  final User user;

  const UserCreateSuccess(this.user);
}

final class UserByIdSuccess extends UserState {
  final User user;

  const UserByIdSuccess(this.user);
}

final class UserListSuccess extends UserState {
  final List<User> users;

  const UserListSuccess(this.users);
}

final class UserUpdateSuccess extends UserState {
  final User user;

  const UserUpdateSuccess(this.user);
}

final class UserDeleteSuccess extends UserState {
  final String id;

  const UserDeleteSuccess(this.id);
}

final class UserError extends UserState {
  final String message;

  const UserError(this.message);
}