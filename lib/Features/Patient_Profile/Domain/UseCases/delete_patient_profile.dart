import 'package:mind_care/Features/Patient_Profile/Domain/Repositories/patient_profile_repository.dart';

class DeletePatientProfile {
  final PatientProfileRepository _repository;

  DeletePatientProfile(this._repository);

  Future<void> call(String id) {
    return _repository.deleteProfile(id);
  }
}