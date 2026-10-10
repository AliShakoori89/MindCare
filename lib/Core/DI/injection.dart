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
import '../../Features/Conversations/Data/Data_Sources/conversation_local_data_source.dart';
import '../../Features/Conversations/Data/Data_Sources/conversation_local_data_source_impl.dart';
import '../../Features/Conversations/Data/Repositories/conversation_repository_impl.dart';
import '../../Features/Conversations/Domain/Repositories/conversation_repository.dart';
import '../../Features/Conversations/Domain/Use_Cases/archive_conversation.dart';
import '../../Features/Conversations/Domain/Use_Cases/create_conversation.dart';
import '../../Features/Conversations/Domain/Use_Cases/get_conversation_by_id.dart';
import '../../Features/Conversations/Domain/Use_Cases/get_conversations_by_user_id.dart';
import '../../Features/Conversations/Domain/Use_Cases/update_conversation.dart';
import '../../Features/Conversations/Presentation/Bloc/conversation_bloc.dart';
import '../../Features/Daily_Checkin/Data/Data_Sources/daily_check_in_local_data_source.dart';
import '../../Features/Daily_Checkin/Data/Repositories/daily_check_in_repository_impl.dart';
import '../../Features/Daily_Checkin/Domain/Repositories/daily_check_in_repository.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/create_daily_check_in.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/delete_daily_check_in.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_id.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_user_and_date.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_ins_by_user_id.dart';
import '../../Features/Daily_Checkin/Domain/Use_Cases/update_daily_check_in.dart';
import '../../Features/Daily_Checkin/Presentation/Bloc/Daily_Check_In_Bloc/daily_check_in_bloc.dart';
import '../../Features/Medications/Data/Data_Sources/medication_local_data_source.dart';
import '../../Features/Medications/Data/Data_Sources/medication_local_data_source_impl.dart';
import '../../Features/Medications/Data/Repositories/medication_repository_impl.dart';
import '../../Features/Medications/Domain/Repositories/medication_repository.dart';
import '../../Features/Medications/Domain/Use_Cases/create_medication.dart';
import '../../Features/Medications/Domain/Use_Cases/delete_medication.dart';
import '../../Features/Medications/Domain/Use_Cases/get_medication_by_id.dart';
import '../../Features/Medications/Domain/Use_Cases/get_medications_by_user_id.dart';
import '../../Features/Medications/Domain/Use_Cases/update_medication.dart';
import '../../Features/Medications/Presentation/Bloc/medication_bloc.dart';
import '../../Features/Messages/Data/Data_Sources/message_local_data_source.dart';
import '../../Features/Messages/Data/Repositories/message_repository_impl.dart';
import '../../Features/Messages/Domain/Repositories/message_repository.dart';
import '../../Features/Messages/Domain/Use_Cases/create_message.dart';
import '../../Features/Messages/Domain/Use_Cases/delete_message.dart';
import '../../Features/Messages/Domain/Use_Cases/get_message_by_id.dart';
import '../../Features/Messages/Domain/Use_Cases/get_messages_by_conversation_id.dart';
import '../../Features/Messages/Domain/Use_Cases/update_message.dart';
import '../../Features/Messages/Presentation/Bloc/message_bloc.dart';
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

import '../Data_Base/Dao/conversations_dao.dart';
import '../Data_Base/Dao/daily_check_ins_dao.dart';
import '../Data_Base/Dao/medications_dao.dart';
import '../Data_Base/Dao/messages_dao.dart';


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

  //-----------------------------------------------------------------------
  sl.registerLazySingleton<MedicationsDao>(
        () => sl<AppDatabase>().medicationsDao,
  );

  sl.registerLazySingleton<MedicationLocalDataSource>(
        () => MedicationLocalDataSourceImpl(
      sl<MedicationsDao>(),
    ),
  );

  sl.registerLazySingleton<MedicationRepository>(
        () => MedicationRepositoryImpl(
      sl<MedicationLocalDataSource>(),
    ),
  );

  sl.registerFactory<CreateMedication>(
        () => CreateMedication(
      sl<MedicationRepository>(),
    ),
  );

  sl.registerFactory<GetMedicationById>(
        () => GetMedicationById(
      sl<MedicationRepository>(),
    ),
  );

  sl.registerFactory<GetMedicationsByUserId>(
        () => GetMedicationsByUserId(
      sl<MedicationRepository>(),
    ),
  );

  sl.registerFactory<UpdateMedication>(
        () => UpdateMedication(
      sl<MedicationRepository>(),
    ),
  );

  sl.registerFactory<DeleteMedication>(
        () => DeleteMedication(
      sl<MedicationRepository>(),
    ),
  );

  sl.registerFactory<MedicationBloc>(
        () => MedicationBloc(
      sl<CreateMedication>(),
      sl<GetMedicationById>(),
      sl<GetMedicationsByUserId>(),
      sl<UpdateMedication>(),
      sl<DeleteMedication>(),
    ),
  );

  //------------------------------------------------------------

  sl.registerLazySingleton<ConversationsDao>(
        () => sl<AppDatabase>().conversationsDao,
  );

  sl.registerLazySingleton<ConversationLocalDataSource>(
        () => ConversationLocalDataSourceImpl(
      sl<ConversationsDao>(),
    ),
  );

  sl.registerLazySingleton<ConversationRepository>(
        () => ConversationRepositoryImpl(
      sl<ConversationLocalDataSource>(),
    ),
  );

  sl.registerFactory<CreateConversation>(
        () => CreateConversation(
      sl<ConversationRepository>(),
    ),
  );

  sl.registerFactory<GetConversationById>(
        () => GetConversationById(
      sl<ConversationRepository>(),
    ),
  );

  sl.registerFactory<GetConversationsByUserId>(
        () => GetConversationsByUserId(
      sl<ConversationRepository>(),
    ),
  );

  sl.registerFactory<UpdateConversation>(
        () => UpdateConversation(
      sl<ConversationRepository>(),
    ),
  );

  sl.registerFactory<ArchiveConversation>(
        () => ArchiveConversation(
      sl<ConversationRepository>(),
    ),
  );

  sl.registerFactory<ConversationBloc>(
        () => ConversationBloc(
      sl<CreateConversation>(),
      sl<GetConversationById>(),
      sl<GetConversationsByUserId>(),
      sl<UpdateConversation>(),
      sl<ArchiveConversation>(),
    ),
  );

  //------------------------------------------------------------------------

  sl.registerLazySingleton<MessagesDao>(
        () => MessagesDao(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<MessageRepository>(
        () => MessageRepositoryImpl(
      sl<MessageLocalDataSource>(),
    ),
  );

  sl.registerFactory(
        () => CreateMessage(
      sl<MessageRepository>(),
    ),
  );

  sl.registerFactory(
        () => GetMessageById(
      sl<MessageRepository>(),
    ),
  );

  sl.registerFactory(
        () => GetMessagesByConversationId(
      sl<MessageRepository>(),
    ),
  );

  sl.registerFactory(
        () => UpdateMessage(
      sl<MessageRepository>(),
    ),
  );

  sl.registerFactory(
        () => DeleteMessage(
      sl<MessageRepository>(),
    ),
  );

  sl.registerFactory(
        () => MessageBloc(
      sl<CreateMessage>(),
      sl<GetMessageById>(),
      sl<GetMessagesByConversationId>(),
      sl<UpdateMessage>(),
      sl<DeleteMessage>(),
    ),
  );

  //------------------------------------------------------------------------
  // Daily Check-In

  sl.registerLazySingleton<DailyCheckInsDao>(
        () => sl<AppDatabase>().dailyCheckInsDao,
  );

  sl.registerLazySingleton<DailyCheckInLocalDataSource>(
        () => DailyCheckInLocalDataSourceImpl(
      sl<DailyCheckInsDao>(),
    ),
  );

  sl.registerLazySingleton<DailyCheckInRepository>(
        () => DailyCheckInRepositoryImpl(
      sl<DailyCheckInLocalDataSource>(),
    ),
  );

  sl.registerFactory<CreateDailyCheckIn>(
        () => CreateDailyCheckIn(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<GetDailyCheckInById>(
        () => GetDailyCheckInById(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<GetDailyCheckInByUserAndDate>(
        () => GetDailyCheckInByUserAndDate(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<GetDailyCheckInsByUserId>(
        () => GetDailyCheckInsByUserId(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<UpdateDailyCheckIn>(
        () => UpdateDailyCheckIn(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<DeleteDailyCheckIn>(
        () => DeleteDailyCheckIn(
      sl<DailyCheckInRepository>(),
    ),
  );

  sl.registerFactory<DailyCheckInBloc>(
        () => DailyCheckInBloc(
      createDailyCheckIn: sl<CreateDailyCheckIn>(),
      getDailyCheckInById: sl<GetDailyCheckInById>(),
      getDailyCheckInByUserAndDate:
      sl<GetDailyCheckInByUserAndDate>(),
      getDailyCheckInsByUserId: sl<GetDailyCheckInsByUserId>(),
      updateDailyCheckIn: sl<UpdateDailyCheckIn>(),
      deleteDailyCheckIn: sl<DeleteDailyCheckIn>(),
    ),
  );
}
