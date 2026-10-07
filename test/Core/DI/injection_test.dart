import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/Patient_Profile_Bloc.dart';

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
}