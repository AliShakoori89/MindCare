import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class CreateMedication {
  final MedicationRepository _repository;

  CreateMedication(this._repository);

  Future<void> call(Medication medication) {
    return _repository.createMedication(medication);
  }
}