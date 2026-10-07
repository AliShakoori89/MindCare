import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';

class CreatePatientProfile {
  final PatientProfileRepository _repository;

  CreatePatientProfile(this._repository);

  Future<void> call(PatientProfile profile) {
    return _repository.createProfile(profile);
  }
}