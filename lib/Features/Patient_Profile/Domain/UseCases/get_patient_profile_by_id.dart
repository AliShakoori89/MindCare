import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart';
import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';

class GetPatientProfileById {
  final PatientProfileRepository _repository;

  GetPatientProfileById(this._repository);

  Future<PatientProfile?> call(String id) {
    return _repository.getProfileById(id);
  }
}