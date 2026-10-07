import 'package:mind_care/Features/Patient_Profile/Data/Data_Sources/patient_profile_local_data_source.dart';
import 'package:mind_care/Features/Patient_Profile/Data/Mappers/patient_profile_mapper.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';

class PatientProfileRepositoryImpl
    implements PatientProfileRepository {
  final PatientProfileLocalDataSource _localDataSource;

  PatientProfileRepositoryImpl(this._localDataSource);

  @override
  Future<void> createProfile(PatientProfile profile) {
    return _localDataSource.insertProfile(
      profile.toCompanion(),
    );
  }

  @override
  Future<PatientProfile?> getProfileById(String id) async {
    final profile = await _localDataSource.getProfileById(id);

    return profile?.toDomain();
  }

  @override
  Future<PatientProfile?> getProfileByUserId(String userId) async {
    final profile =
    await _localDataSource.getProfileByUserId(userId);

    return profile?.toDomain();
  }

  @override
  Future<void> updateProfile(PatientProfile profile) async {
    await _localDataSource.updateProfile(
      profile.toCompanion(),
    );
  }

  @override
  Future<void> deleteProfile(String id) async {
    await _localDataSource.deleteProfile(id);
  }
}