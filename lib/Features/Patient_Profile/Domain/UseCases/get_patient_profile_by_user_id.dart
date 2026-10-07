import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';

class GetPatientProfileByUserId {
  final PatientProfileRepository _repository;

  GetPatientProfileByUserId(this._repository);

  Future<PatientProfile?> call(String userId) {
    return _repository.getProfileByUserId(userId);
  }
}