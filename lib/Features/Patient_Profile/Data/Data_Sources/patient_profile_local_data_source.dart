import 'package:mind_care/Core/Data_Base/app_database.dart';

abstract interface class PatientProfileLocalDataSource {
  Future<void> insertProfile(PatientProfilesCompanion profile);

  Future<PatientProfile?> getProfileById(String id);

  Future<PatientProfile?> getProfileByUserId(String userId);

  Future<bool> updateProfile(PatientProfilesCompanion profile);

  Future<int> deleteProfile(String id);
}