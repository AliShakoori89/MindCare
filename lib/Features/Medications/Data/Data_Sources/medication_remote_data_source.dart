
import '../Models/medication_model.dart';

abstract interface class MedicationRemoteDataSource {
  Future<MedicationModel> getMedicationById(String id);

  Future<MedicationModel> createMedication({
    required String id,
    required String name,
    String? genericName,
    String? dosage,
    String? unit,
    required String frequencyType,
    String? frequencyValue,
    required String route,
    DateTime? startDate,
    DateTime? endDate,
    required String status,
    String? prescribedBy,
    String? notes,
  });

  Future<MedicationModel> updateMedication({
    required String id,
    required String name,
    String? genericName,
    String? dosage,
    String? unit,
    required String frequencyType,
    String? frequencyValue,
    required String route,
    DateTime? startDate,
    DateTime? endDate,
    required String status,
    String? prescribedBy,
    String? notes,
  });

  Future<void> deleteMedication(String id);
}
