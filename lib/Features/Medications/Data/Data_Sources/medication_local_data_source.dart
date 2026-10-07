import 'package:mind_care/Core/Data_Base/app_database.dart';

abstract interface class MedicationLocalDataSource {
  Future<void> insertMedication(
      MedicationsCompanion medication,
      );

  Future<Medication?> getMedicationById(
      String id,
      );

  Future<List<Medication>> getMedicationsByUserId(
      String userId,
      );

  Future<bool> updateMedication(
      MedicationsCompanion medication,
      );

  Future<int> deleteMedication(
      String id,
      );
}