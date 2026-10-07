import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class GetMedicationsByUserId {
  final MedicationRepository _repository;

  GetMedicationsByUserId(this._repository);

  Future<List<Medication>> call(String userId) {
    return _repository.getMedicationsByUserId(userId);
  }
}