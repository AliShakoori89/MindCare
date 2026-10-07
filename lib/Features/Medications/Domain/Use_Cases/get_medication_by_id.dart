import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class GetMedicationById {
  final MedicationRepository _repository;

  GetMedicationById(this._repository);

  Future<Medication?> call(String id) {
    return _repository.getMedicationById(id);
  }
}