import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class UpdateMedication {
  final MedicationRepository _repository;

  UpdateMedication(this._repository);

  Future<void> call(Medication medication) {
    return _repository.updateMedication(medication);
  }
}