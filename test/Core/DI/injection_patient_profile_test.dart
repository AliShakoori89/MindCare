import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';

void main() {
  final sl = GetIt.instance;

  setUp(() {
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset(dispose: true);
  });

  test('PatientProfile dependencies should be registered', () {
    expect(
      sl.isRegistered<PatientProfileLocalDataSource>(),
      isTrue,
    );

    expect(
      sl.isRegistered<PatientProfileRepository>(),
      isTrue,
    );

    expect(
      sl.isRegistered<CreatePatientProfile>(),
      isTrue,
    );

    expect(
      sl.isRegistered<GetPatientProfileById>(),
      isTrue,
    );

    expect(
      sl.isRegistered<GetPatientProfileByUserId>(),
      isTrue,
    );

    expect(
      sl.isRegistered<UpdatePatientProfile>(),
      isTrue,
    );

    expect(
      sl.isRegistered<DeletePatientProfile>(),
      isTrue,
    );
  });

  test('PatientProfile dependencies should resolve', () {
    expect(
          () => sl<PatientProfileLocalDataSource>(),
      returnsNormally,
    );

    expect(
          () => sl<PatientProfileRepository>(),
      returnsNormally,
    );

    expect(
          () => sl<CreatePatientProfile>(),
      returnsNormally,
    );

    expect(
          () => sl<GetPatientProfileById>(),
      returnsNormally,
    );

    expect(
          () => sl<GetPatientProfileByUserId>(),
      returnsNormally,
    );

    expect(
          () => sl<UpdatePatientProfile>(),
      returnsNormally,
    );

    expect(
          () => sl<DeletePatientProfile>(),
      returnsNormally,
    );
  });

  test('UseCases should be factory instances', () {
    final first = sl<CreatePatientProfile>();
    final second = sl<CreatePatientProfile>();

    expect(identical(first, second), isFalse);
  });

  test('Repository should be singleton', () {
    final first = sl<PatientProfileRepository>();
    final second = sl<PatientProfileRepository>();

    expect(identical(first, second), isTrue);
  });
}