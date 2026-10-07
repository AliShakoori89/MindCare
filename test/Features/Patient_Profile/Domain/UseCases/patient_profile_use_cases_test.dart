import 'package:flutter_test/flutter_test.dart';

import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';

class FakePatientProfileRepository
    implements PatientProfileRepository {
  PatientProfile? storedProfile;

  @override
  Future<void> createProfile(PatientProfile profile) async {
    storedProfile = profile;
  }

  @override
  Future<PatientProfile?> getProfileById(String id) async {
    if (storedProfile?.id != id) {
      return null;
    }

    return storedProfile;
  }

  @override
  Future<PatientProfile?> getProfileByUserId(String userId) async {
    if (storedProfile?.userId != userId) {
      return null;
    }

    return storedProfile;
  }

  @override
  Future<void> updateProfile(PatientProfile profile) async {
    storedProfile = profile;
  }

  @override
  Future<void> deleteProfile(String id) async {
    if (storedProfile?.id == id) {
      storedProfile = null;
    }
  }
}

void main() {
  late FakePatientProfileRepository repository;

  late CreatePatientProfile createPatientProfile;
  late GetPatientProfileById getPatientProfileById;
  late GetPatientProfileByUserId getPatientProfileByUserId;
  late UpdatePatientProfile updatePatientProfile;
  late DeletePatientProfile deletePatientProfile;

  final now = DateTime(2026, 1, 1);

  final profile = PatientProfile(
    id: 'profile-1',
    userId: 'user-1',
    firstName: 'Ali',
    lastName: 'Shakoori',
    birthDate: DateTime(1995, 5, 10),
    gender: 'male',
    preferredLanguage: 'fa',
    emergencyContactName: 'Sara',
    emergencyContactRelationship: 'sister',
    emergencyContactPhone: '09120000000',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    repository = FakePatientProfileRepository();

    createPatientProfile = CreatePatientProfile(repository);
    getPatientProfileById = GetPatientProfileById(repository);
    getPatientProfileByUserId = GetPatientProfileByUserId(repository);
    updatePatientProfile = UpdatePatientProfile(repository);
    deletePatientProfile = DeletePatientProfile(repository);
  });

  test('CreatePatientProfile should create profile', () async {
    await createPatientProfile(profile);

    expect(repository.storedProfile, isNotNull);
    expect(repository.storedProfile!.id, profile.id);
    expect(repository.storedProfile!.userId, profile.userId);
  });

  test('GetPatientProfileById should return profile', () async {
    repository.storedProfile = profile;

    final result = await getPatientProfileById(profile.id);

    expect(result, isNotNull);
    expect(result!.id, profile.id);
    expect(result.userId, profile.userId);
  });

  test(
    'GetPatientProfileById should return null when profile does not exist',
        () async {
      final result = await getPatientProfileById('not-found');

      expect(result, isNull);
    },
  );

  test('GetPatientProfileByUserId should return profile', () async {
    repository.storedProfile = profile;

    final result = await getPatientProfileByUserId(
      profile.userId,
    );

    expect(result, isNotNull);
    expect(result!.id, profile.id);
    expect(result.userId, profile.userId);
  });

  test(
    'GetPatientProfileByUserId should return null when profile does not exist',
        () async {
      final result = await getPatientProfileByUserId(
        'not-found',
      );

      expect(result, isNull);
    },
  );

  test('UpdatePatientProfile should update profile', () async {
    repository.storedProfile = profile;

    final updatedProfile = PatientProfile(
      id: profile.id,
      userId: profile.userId,
      firstName: 'Alireza',
      lastName: 'Updated',
      birthDate: profile.birthDate,
      gender: 'other',
      preferredLanguage: 'en',
      emergencyContactName: profile.emergencyContactName,
      emergencyContactRelationship:
      profile.emergencyContactRelationship,
      emergencyContactPhone: profile.emergencyContactPhone,
      createdAt: profile.createdAt,
      updatedAt: DateTime(2026, 2, 1),
    );

    await updatePatientProfile(updatedProfile);

    expect(repository.storedProfile, isNotNull);
    expect(
      repository.storedProfile!.firstName,
      'Alireza',
    );
    expect(
      repository.storedProfile!.lastName,
      'Updated',
    );
    expect(
      repository.storedProfile!.gender,
      'other',
    );
    expect(
      repository.storedProfile!.preferredLanguage,
      'en',
    );
  });

  test('DeletePatientProfile should delete profile', () async {
    repository.storedProfile = profile;

    await deletePatientProfile(profile.id);

    expect(repository.storedProfile, isNull);
  });
}