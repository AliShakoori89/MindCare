import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/Patient_Profile_Bloc.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/create_condition.dart';
import 'package:mind_care/Features/Conditions/Presentation/Bloc/condition_bloc.dart';

void main() {
  setUp(() async {
    await sl.reset();
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  test('PatientProfile dependency graph should resolve', () {
    expect(
      sl<AppDatabase>(),
      isA<AppDatabase>(),
    );

    expect(
      sl<PatientProfileLocalDataSource>(),
      isA<PatientProfileLocalDataSource>(),
    );

    expect(
      sl<PatientProfileRepository>(),
      isA<PatientProfileRepository>(),
    );

    expect(
      sl<CreatePatientProfile>(),
      isA<CreatePatientProfile>(),
    );

    expect(
      sl<GetPatientProfileById>(),
      isA<GetPatientProfileById>(),
    );

    expect(
      sl<GetPatientProfileByUserId>(),
      isA<GetPatientProfileByUserId>(),
    );

    expect(
      sl<UpdatePatientProfile>(),
      isA<UpdatePatientProfile>(),
    );

    expect(
      sl<DeletePatientProfile>(),
      isA<DeletePatientProfile>(),
    );

    expect(
      sl<PatientProfileBloc>(),
      isA<PatientProfileBloc>(),
    );
  });

  test('Condition dependency graph should resolve', () {
    expect(
      sl<ConditionLocalDataSource>(),
      isA<ConditionLocalDataSource>(),
    );

    expect(
      sl<ConditionRepository>(),
      isA<ConditionRepository>(),
    );

    expect(
      sl<CreateCondition>(),
      isA<CreateCondition>(),
    );

    expect(
      sl<ConditionBloc>(),
      isA<ConditionBloc>(),
    );
  });

  test('ConditionRepository should be a lazy singleton', () {
    final first = sl<ConditionRepository>();
    final second = sl<ConditionRepository>();

    expect(identical(first, second), isTrue);
  });

  test('ConditionBloc should be a factory', () {
    final first = sl<ConditionBloc>();
    final second = sl<ConditionBloc>();

    expect(identical(first, second), isFalse);
  });

  test('PatientProfileRepository should be a lazy singleton', () {
    final first = sl<PatientProfileRepository>();
    final second = sl<PatientProfileRepository>();

    expect(identical(first, second), isTrue);
  });

  test('PatientProfileBloc should be a factory', () {
    final first = sl<PatientProfileBloc>();
    final second = sl<PatientProfileBloc>();

    expect(identical(first, second), isFalse);
  });

  test('SyncRemoteDataSource dependency should resolve', () {
    expect(
      sl<SyncRemoteDataSource>(),
      isA<SyncRemoteDataSource>(),
    );
  });

  test('SyncRemoteDataSource should be a lazy singleton', () {
    final first = sl<SyncRemoteDataSource>();
    final second = sl<SyncRemoteDataSource>();

    expect(identical(first, second), isTrue);
  });
}