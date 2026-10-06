import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/Features/User/Domain/UseCases/create_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/delete_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_all_users.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_user_by_id.dart';
import 'package:mind_care/Features/User/Domain/UseCases/update_user.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final CreateUser _createUser;
  final GetUserById _getUserById;
  final GetAllUsers _getAllUsers;
  final UpdateUser _updateUser;
  final DeleteUser _deleteUser;

  UserBloc(
      this._createUser,
      this._getUserById,
      this._getAllUsers,
      this._updateUser,
      this._deleteUser,
      ) : super(const UserInitial()) {
    on<CreateUserEvent>(_onCreateUser);
    on<GetUserByIdEvent>(_onGetUserById);
    on<GetAllUsersEvent>(_onGetAllUsers);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onCreateUser(
      CreateUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      await _createUser(event.user);

      emit(
        UserCreateSuccess(event.user),
      );
    } catch (e) {
      emit(
        UserError(e.toString()),
      );
    }
  }

  Future<void> _onGetUserById(
      GetUserByIdEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final user = await _getUserById(event.id);

      if (user == null) {
        emit(
          const UserError('User not found'),
        );
        return;
      }

      emit(
        UserByIdSuccess(user),
      );
    } catch (e) {
      emit(
        UserError(e.toString()),
      );
    }
  }

  Future<void> _onGetAllUsers(
      GetAllUsersEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final users = await _getAllUsers();

      emit(
        UserListSuccess(users),
      );
    } catch (e) {
      emit(
        UserError(e.toString()),
      );
    }
  }

  Future<void> _onUpdateUser(
      UpdateUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      await _updateUser(event.user);

      emit(
        UserUpdateSuccess(event.user),
      );
    } catch (e) {
      emit(
        UserError(e.toString()),
      );
    }
  }

  Future<void> _onDeleteUser(
      DeleteUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      await _deleteUser(event.id);

      emit(
        UserDeleteSuccess(event.id),
      );
    } catch (e) {
      emit(
        UserError(e.toString()),
      );
    }
  }
}