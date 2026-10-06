import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Features/User/Domain/UseCases/create_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/delete_user.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_all_users.dart';
import 'package:mind_care/Features/User/Domain/UseCases/get_user_by_id.dart';
import 'package:mind_care/Features/User/Domain/UseCases/update_user.dart';
import 'package:mind_care/Features/User/Presentation/Bloc/User_Bloc/user_bloc.dart';

void main() {
  setUp(() {
    sl.reset();
  });

  tearDown(() async {
    await sl.reset(dispose: true);
  });

  test('registers AppDatabase and UsersDao', () {
    configureDependencies();

    expect(sl.isRegistered<AppDatabase>(), isTrue);
    expect(sl.isRegistered<UsersDao>(), isTrue);
  });

  test('resolves AppDatabase', () {
    configureDependencies();

    final database = sl<AppDatabase>();

    expect(database, isA<AppDatabase>());
  });

  test('resolves UsersDao with AppDatabase dependency', () {
    configureDependencies();

    final usersDao = sl<UsersDao>();

    expect(usersDao, isA<UsersDao>());
  });

  test('resolves CreateUser with all dependencies', () {
    configureDependencies();

    final createUser = sl<CreateUser>();

    expect(createUser, isA<CreateUser>());
  });

  test('resolves all User use cases with dependencies', () {
    configureDependencies();

    expect(sl<CreateUser>(), isA<CreateUser>());
    expect(sl<GetUserById>(), isA<GetUserById>());
    expect(sl<GetAllUsers>(), isA<GetAllUsers>());
    expect(sl<UpdateUser>(), isA<UpdateUser>());
    expect(sl<DeleteUser>(), isA<DeleteUser>());
  });

  test('resolves UserBloc with its dependencies', () {
    configureDependencies();

    final userBloc = sl<UserBloc>();

    expect(userBloc, isA<UserBloc>());
  });
}