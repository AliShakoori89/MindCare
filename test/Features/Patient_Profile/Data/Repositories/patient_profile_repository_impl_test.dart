import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/patient_profiles_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source_impl.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Repositories/patient_profile_repository_impl.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart' as domain;

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late PatientProfilesDao patientProfilesDao;
  late PatientProfileLocalDataSource localDataSource;
  late PatientProfileRepositoryImpl repository;

  const userId = 'user-1';
  const profileId = 'profile-1';

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  domain.PatientProfile createProfile({
    String firstName = 'Ali',
    String lastName = 'Shakoori',
  }) {
    return domain.PatientProfile(
      id: profileId,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      birthDate: DateTime(1995, 1, 1),
      gender: 'male',
      preferredLanguage: 'fa',
      emergencyContactName: 'Sara',
      emergencyContactRelationship: 'sister',
      emergencyContactPhone: '09120000000',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Future<void> createUser() async {
    await usersDao.insertUser(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    patientProfilesDao = PatientProfilesDao(database);

    localDataSource = PatientProfileLocalDataSourceImpl(
      patientProfilesDao,
    );

    repository = PatientProfileRepositoryImpl(
      localDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createProfile should persist the profile',
        () async {
      await createUser();

      final profile = createProfile();

      await repository.createProfile(profile);

      final result = await repository.getProfileById(profileId);

      expect(result, isNotNull);
      expect(result?.id, profileId);
      expect(result?.userId, userId);
      expect(result?.firstName, 'Ali');
      expect(result?.lastName, 'Shakoori');
    },
  );

  test(
    'getProfileById should return null when profile does not exist',
        () async {
      final result = await repository.getProfileById(
        profileId,
      );

      expect(result, isNull);
    },
  );

  test(
    'getProfileByUserId should return the profile',
        () async {
      await createUser();

      final profile = createProfile();

      await repository.createProfile(profile);

      final result = await repository.getProfileByUserId(
        userId,
      );

      expect(result, isNotNull);
      expect(result?.id, profileId);
      expect(result?.userId, userId);
      expect(result?.firstName, 'Ali');
    },
  );

  test(
    'updateProfile should update the profile',
        () async {
      await createUser();

      await repository.createProfile(
        createProfile(),
      );

      final updatedProfile = createProfile(
        firstName: 'Alireza',
        lastName: 'Ahmadi',
      );

      await repository.updateProfile(
        updatedProfile,
      );

      final result = await repository.getProfileById(
        profileId,
      );

      expect(result, isNotNull);
      expect(result?.firstName, 'Alireza');
      expect(result?.lastName, 'Ahmadi');
    },
  );

  test(
    'deleteProfile should delete the profile',
        () async {
      await createUser();

      await repository.createProfile(
        createProfile(),
      );

      await repository.deleteProfile(
        profileId,
      );

      final result = await repository.getProfileById(
        profileId,
      );

      expect(result, isNull);
    },
  );
}