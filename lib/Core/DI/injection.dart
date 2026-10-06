import 'package:get_it/get_it.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import '../../Features/User/Data/Data_Sources/user_local_data_source.dart';
import '../../Features/User/Data/Data_Sources/user_local_data_source_impl.dart';
import '../../Features/User/Data/Repositories/user_repository_impl.dart';
import '../../Features/User/Domain/Repositories/user_repository.dart';
import '../../Features/User/Domain/UseCases/create_user.dart';
import '../../Features/User/Domain/UseCases/delete_user.dart';
import '../../Features/User/Domain/UseCases/get_all_users.dart';
import '../../Features/User/Domain/UseCases/get_user_by_id.dart';
import '../../Features/User/Domain/UseCases/update_user.dart';
import '../../Features/User/Presentation/Bloc/User_Bloc/user_bloc.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<AppDatabase>(
    AppDatabase.new,
    dispose: (database) => database.close(),
  );

  sl.registerLazySingleton<UsersDao>(
        () => UsersDao(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<UserLocalDataSource>(
        () => UserLocalDataSourceImpl(
      sl<UsersDao>(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
      sl<UserLocalDataSource>(),
    ),
  );

  sl.registerFactory<CreateUser>(
        () => CreateUser(
      sl<UserRepository>(),
    ),
  );

  sl.registerFactory<GetUserById>(
        () => GetUserById(
      sl<UserRepository>(),
    ),
  );

  sl.registerFactory<GetAllUsers>(
        () => GetAllUsers(
      sl<UserRepository>(),
    ),
  );

  sl.registerFactory<UpdateUser>(
        () => UpdateUser(
      sl<UserRepository>(),
    ),
  );

  sl.registerFactory<DeleteUser>(
        () => DeleteUser(
      sl<UserRepository>(),
    ),
  );

  sl.registerFactory<UserBloc>(
        () => UserBloc(
      sl<CreateUser>(),
      sl<GetUserById>(),
      sl<GetAllUsers>(),
      sl<UpdateUser>(),
      sl<DeleteUser>(),
    ),
  );
}
