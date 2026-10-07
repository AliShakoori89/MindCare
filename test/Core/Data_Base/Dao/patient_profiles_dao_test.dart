import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/patient_profiles_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late PatientProfilesDao patientProfilesDao;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    patientProfilesDao = PatientProfilesDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  const userId = 'user-1';
  const profileId = 'profile-1';

  final now = DateTime(2026, 1, 1);

  Future<void> createUser() {
    return usersDao.insertUser(
      UsersCompanion.insert(
        id: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  PatientProfilesCompanion createProfile({
    String id = profileId,
    String firstName = 'Ali',
    String lastName = 'Shakoori',
    DateTime? birthDate,
    String gender = 'male',
    String preferredLanguage = 'fa',
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfilesCompanion.insert(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      birthDate: drift.Value(birthDate),
      gender: gender,
      preferredLanguage: preferredLanguage,
      emergencyContactName: drift.Value(emergencyContactName),
      emergencyContactRelationship: drift.Value(
        emergencyContactRelationship,
      ),
      emergencyContactPhone: drift.Value(
        emergencyContactPhone,
      ),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  test('watchProfileByUserId should emit changes', () async {
    await createUser();

    final stream = patientProfilesDao
        .watchProfileByUserId(userId)
        .map((profile) => profile?.firstName);

    final expectation = expectLater(
      stream,
      emitsInOrder([
        'Ali',
        'Alireza',
      ]),
    );

    await patientProfilesDao.insertProfile(
      createProfile(),
    );

    await patientProfilesDao.updateProfile(
      createProfile(
        firstName: 'Alireza',
      ),
    );

    await expectation;

    await patientProfilesDao.deleteProfile(
      profileId,
    );

    final profile = await patientProfilesDao.getProfileById(
      profileId,
    );

    expect(profile, isNull);
  });

  test(
    'deleting a user should cascade delete its patient profile',
        () async {
      final user = UsersCompanion.insert(
        id: userId,
        createdAt: now,
        updatedAt: now,
      );

      await usersDao.insertUser(user);

      final profile = PatientProfilesCompanion.insert(
        id: 'profile-1',
        userId: 'user-1',
        firstName: 'Ali',
        lastName: 'Shakoori',
        gender: 'male',
        preferredLanguage: 'fa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await patientProfilesDao.insertProfile(profile);

      // قبل از حذف User باید Profile وجود داشته باشد.
      expect(
        await patientProfilesDao.getProfileById('profile-1'),
        isNotNull,
      );

      // حذف User
      await usersDao.deleteUser('user-1');

      // Profile باید به صورت Cascade حذف شده باشد.
      expect(
        await patientProfilesDao.getProfileById('profile-1'),
        isNull,
      );
    },
  );

  test(
    'insertProfile should fail when userId does not exist',
        () async {
      final profile = PatientProfilesCompanion.insert(
        id: 'profile-1',
        userId: 'non-existing-user',
        firstName: 'Ali',
        lastName: 'Shakoori',
        gender: 'male',
        preferredLanguage: 'fa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
            () => patientProfilesDao.insertProfile(profile),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('insertProfile and getProfileById should work', () async {
    await createUser();

    await patientProfilesDao.insertProfile(
      createProfile(),
    );

    final profile = await patientProfilesDao.getProfileById(
      profileId,
    );

    expect(profile, isNotNull);
    expect(profile!.id, profileId);
    expect(profile.userId, userId);
    expect(profile.firstName, 'Ali');
    expect(profile.lastName, 'Shakoori');
    expect(profile.gender, 'male');
    expect(profile.preferredLanguage, 'fa');
  });

  test('getProfileById should return null when profile does not exist', () async {
    final profile = await patientProfilesDao.getProfileById(
      'not-found',
    );

    expect(profile, isNull);
  });

  test('getProfileByUserId should return the user profile', () async {
    await createUser();

    await patientProfilesDao.insertProfile(
      createProfile(),
    );

    final profile = await patientProfilesDao.getProfileByUserId(
      userId,
    );

    expect(profile, isNotNull);
    expect(profile!.id, profileId);
    expect(profile.userId, userId);
  });

  test('updateProfile should update the profile', () async {
    await createUser();

    await patientProfilesDao.insertProfile(
      createProfile(),
    );

    final updatedTime = DateTime(2026, 2, 1);

    final updatedProfile = createProfile(
      firstName: 'Alireza',
      lastName: 'Updated',
      gender: 'other',
      preferredLanguage: 'en',
      updatedAt: updatedTime,
    );

    final result = await patientProfilesDao.updateProfile(
      updatedProfile,
    );

    expect(result, isTrue);

    final profile = await patientProfilesDao.getProfileById(
      profileId,
    );

    expect(profile, isNotNull);
    expect(profile!.firstName, 'Alireza');
    expect(profile.lastName, 'Updated');
    expect(profile.gender, 'other');
    expect(profile.preferredLanguage, 'en');
    expect(profile.updatedAt, updatedTime);
  });

  test('deleteProfile should delete the profile', () async {
    await createUser();

    await patientProfilesDao.insertProfile(
      createProfile(),
    );

    final deletedRows = await patientProfilesDao.deleteProfile(
      profileId,
    );

    expect(deletedRows, 1);

    final profile = await patientProfilesDao.getProfileById(
      profileId,
    );

    expect(profile, isNull);
  });

  test('userId should be unique across patient profiles', () async {
    await createUser();

    await patientProfilesDao.insertProfile(
      createProfile(
        id: profileId,
      ),
    );

    expect(
          () => patientProfilesDao.insertProfile(
        createProfile(
          id: 'profile-2',
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });
}