import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';

abstract interface class PatientProfileRepository {
  Future<void> createProfile(PatientProfile profile);

  Future<PatientProfile?> getProfileById(String id);

  Future<PatientProfile?> getProfileByUserId(String userId);

  Future<void> updateProfile(PatientProfile profile);

  Future<void> deleteProfile(String id);
}