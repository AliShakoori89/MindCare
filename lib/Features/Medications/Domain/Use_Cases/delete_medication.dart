import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class DeleteMedication {
  final MedicationRepository _repository;

  DeleteMedication(this._repository);

  Future<void> call({
    required String id,
    required String userId,
  }) {
    return _repository.deleteMedication(
      id: id,
      userId: userId,
    );
  }
}
