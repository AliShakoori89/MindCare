import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/create_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/delete_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/get_patient_profile_by_user_id.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/UseCases/update_patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/patient_profile_bloc.dart';
import 'package:mind_care/Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/patient_profile_event.dart';
import 'package:mind_care/Features/Patient_Profile/Presentation/Bloc/Patient_Profile_Bloc/patient_profile_state.dart';
import 'package:bloc_test/bloc_test.dart';

class FakePatientProfileRepository implements PatientProfileRepository {
  PatientProfile? profile;

  bool shouldThrow = false;

  @override
  Future<void> createProfile(PatientProfile profile) async {
    if (shouldThrow) {
      throw Exception('Create profile failed');
    }

    this.profile = profile;
  }

  @override
  Future<PatientProfile?> getProfileById(String id) async {
    if (shouldThrow) {
      throw Exception('Get profile failed');
    }

    if (profile?.id == id) {
      return profile;
    }

    return null;
  }

  @override
  Future<PatientProfile?> getProfileByUserId(String userId) async {
    if (shouldThrow) {
      throw Exception('Get profile failed');
    }

    if (profile?.userId == userId) {
      return profile;
    }

    return null;
  }

  @override
  Future<void> updateProfile(PatientProfile profile) async {
    if (shouldThrow) {
      throw Exception('Update profile failed');
    }

    this.profile = profile;
  }

  @override
  Future<void> deleteProfile(String id) async {
    if (shouldThrow) {
      throw Exception('Delete profile failed');
    }

    if (profile?.id == id) {
      profile = null;
    }
  }
}

PatientProfile createTestProfile() {
  return PatientProfile(
    id: 'profile-1',
    userId: 'user-1',
    firstName: 'Ali',
    lastName: 'Shakoori',
    birthDate: DateTime(1990, 1, 1),
    gender: 'male',
    preferredLanguage: 'fa',
    emergencyContactName: 'Test Contact',
    emergencyContactRelationship: 'brother',
    emergencyContactPhone: '09120000000',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late FakePatientProfileRepository repository;
  late PatientProfileBloc bloc;

  setUp(() {
    repository = FakePatientProfileRepository();

    bloc = PatientProfileBloc(
      CreatePatientProfile(repository),
      GetPatientProfileById(repository),
      GetPatientProfileByUserId(repository),
      UpdatePatientProfile(repository),
      DeletePatientProfile(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('PatientProfileBloc', () {
    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Created when profile is created',
      build: () => bloc,
      act: (bloc) => bloc.add(
        CreatePatientProfileEvent(createTestProfile()),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileCreated>().having(
              (state) => state.profile.id,
          'profile id',
          'profile-1',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Loaded when profile is found by id',
      build: () {
        repository.profile = createTestProfile();
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetPatientProfileByIdEvent('profile-1'),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileLoaded>().having(
              (state) => state.profile.id,
          'profile id',
          'profile-1',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Error when profile is not found by id',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const GetPatientProfileByIdEvent('unknown-profile'),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileError>().having(
              (state) => state.message,
          'message',
          'Patient profile not found.',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Loaded when profile is found by user id',
      build: () {
        repository.profile = createTestProfile();
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetPatientProfileByUserIdEvent('user-1'),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileLoaded>().having(
              (state) => state.profile.userId,
          'user id',
          'user-1',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Error when profile is not found by user id',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const GetPatientProfileByUserIdEvent('unknown-user'),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileError>().having(
              (state) => state.message,
          'message',
          'Patient profile not found.',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Updated when profile is updated',
      build: () {
        repository.profile = createTestProfile();

        return bloc;
      },
      act: (bloc) {
        final updatedProfile = createTestProfile().copyWith(
          firstName: 'Updated',
        );

        bloc.add(
          UpdatePatientProfileEvent(updatedProfile),
        );
      },
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileUpdated>().having(
              (state) => state.profile.firstName,
          'first name',
          'Updated',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Loading and Deleted when profile is deleted',
      build: () {
        repository.profile = createTestProfile();
        return bloc;
      },
      act: (bloc) => bloc.add(
        const DeletePatientProfileEvent('profile-1'),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileDeleted>(),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Error when create fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) => bloc.add(
        CreatePatientProfileEvent(createTestProfile()),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileError>().having(
              (state) => state.message,
          'message',
          'Exception: Create profile failed',
        ),
      ],
    );

    blocTest<PatientProfileBloc, PatientProfileState>(
      'emits Error when update fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdatePatientProfileEvent(createTestProfile()),
      ),
      expect: () => [
        isA<PatientProfileLoading>(),
        isA<PatientProfileError>().having(
              (state) => state.message,
          'message',
          'Exception: Update profile failed',
        ),
      ],
    );
  });
}