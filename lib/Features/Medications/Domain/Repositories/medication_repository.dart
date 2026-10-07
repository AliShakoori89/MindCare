import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';

abstract interface class MedicationRepository {
  Future<void> createMedication(Medication medication);

  Future<Medication?> getMedicationById(String id);

  Future<List<Medication>> getMedicationsByUserId(String userId);

  Future<void> updateMedication(Medication medication);

  Future<void> deleteMedication(String id);
}