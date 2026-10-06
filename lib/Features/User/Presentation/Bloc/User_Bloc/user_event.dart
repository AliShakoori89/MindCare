import 'package:mind_care/Features/User/Domain/Entities/user.dart';

sealed class UserEvent {
  const UserEvent();
}

final class CreateUserEvent extends UserEvent {
  final User user;

  const CreateUserEvent(this.user);
}

final class GetUserByIdEvent extends UserEvent {
  final String id;

  const GetUserByIdEvent(this.id);
}

final class GetAllUsersEvent extends UserEvent {
  const GetAllUsersEvent();
}

final class UpdateUserEvent extends UserEvent {
  final User user;

  const UpdateUserEvent(this.user);
}

final class DeleteUserEvent extends UserEvent {
  final String id;

  const DeleteUserEvent(this.id);
}