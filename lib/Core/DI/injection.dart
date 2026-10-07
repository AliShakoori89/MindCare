import 'package:get_it/get_it.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import '../../Features/Conditions/Domain/Repositories/condition_repository.dart';
import '../../Features/Conditions/Domain/Use_Cases/create_condition.dart';
import '../../Features/Conditions/Domain/Use_Cases/delete_condition.dart';
import '../../Features/Conditions/Domain/Use_Cases/get_condition_by_id.dart';
import '../../Features/Conditions/Domain/Use_Cases/get_conditions_by_user_id.dart';
import '../../Features/Conditions/Domain/Use_Cases/update_condition.dart';
import '../../Features/Conditions/Presentation/Bloc/condition_bloc.dart';
import '../../Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/Patient_Profile_Bloc.dart';
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
import 'package:mind_care/Core/Data_Base/Dao/patient_profiles_dao.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source_impl.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Repositories/patient_profile_repository_impl.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';


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

  //--------------------------------------------------------------------------

  sl.registerLazySingleton<PatientProfilesDao>(
        () => PatientProfilesDao(
      sl<AppDatabase>(),
    ),
  );

  sl.registerLazySingleton<PatientProfileLocalDataSource>(
        () => PatientProfileLocalDataSourceImpl(
      sl<PatientProfilesDao>(),
    ),
  );

  sl.registerLazySingleton<PatientProfileRepository>(
        () => PatientProfileRepositoryImpl(
      sl<PatientProfileLocalDataSource>(),
    ),
  );

  sl.registerFactory<CreatePatientProfile>(
        () => CreatePatientProfile(
      sl<PatientProfileRepository>(),
    ),
  );

  sl.registerFactory<GetPatientProfileById>(
        () => GetPatientProfileById(
      sl<PatientProfileRepository>(),
    ),
  );

  sl.registerFactory<GetPatientProfileByUserId>(
        () => GetPatientProfileByUserId(
      sl<PatientProfileRepository>(),
    ),
  );

  sl.registerFactory<UpdatePatientProfile>(
        () => UpdatePatientProfile(
      sl<PatientProfileRepository>(),
    ),
  );

  sl.registerFactory<DeletePatientProfile>(
        () => DeletePatientProfile(
      sl<PatientProfileRepository>(),
    ),
  );

  sl.registerFactory<PatientProfileBloc>(
        () => PatientProfileBloc(
      sl<CreatePatientProfile>(),
      sl<GetPatientProfileById>(),
      sl<GetPatientProfileByUserId>(),
      sl<UpdatePatientProfile>(),
      sl<DeletePatientProfile>(),
    ),
  );

  //------------------------------------------------------------------

  sl.registerFactory<CreateCondition>(
        () => CreateCondition(
      sl<ConditionRepository>(),
    ),
  );

  sl.registerFactory<GetConditionById>(
        () => GetConditionById(
      sl<ConditionRepository>(),
    ),
  );

  sl.registerFactory<GetConditionsByUserId>(
        () => GetConditionsByUserId(
      sl<ConditionRepository>(),
    ),
  );

  sl.registerFactory<UpdateCondition>(
        () => UpdateCondition(
      sl<ConditionRepository>(),
    ),
  );

  sl.registerFactory<DeleteCondition>(
        () => DeleteCondition(
      sl<ConditionRepository>(),
    ),
  );

  sl.registerFactory<ConditionBloc>(
        () => ConditionBloc(
      createCondition: sl<CreateCondition>(),
      getConditionById: sl<GetConditionById>(),
      getConditionsByUserId: sl<GetConditionsByUserId>(),
      updateCondition: sl<UpdateCondition>(),
      deleteCondition: sl<DeleteCondition>(),
    ),
  );
}
