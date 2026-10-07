import 'package:drift/drift.dart';
import '../Tables/medications.dart';
import '../app_database.dart';
part 'medications_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  Future<void> insertMedication(
      MedicationsCompanion medication,
      ) {
    return into(medications).insert(medication);
  }

  Future<Medication?> getMedicationById(String id) {
    return (select(medications)
      ..where(
            (medication) =>
        medication.id.equals(id) &
        medication.deletedAt.isNull(),
      ))
        .getSingleOrNull();
  }

  Future<List<Medication>> getMedicationsByUserId(
      String userId,
      ) {
    return (select(medications)
      ..where(
            (medication) =>
        medication.userId.equals(userId) &
        medication.deletedAt.isNull(),
      ))
        .get();
  }

  Future<bool> updateMedication(
      MedicationsCompanion medication,
      ) {
    return update(medications).replace(medication);
  }

  Future<int> deleteMedication(String id) {
    final now = DateTime.now();

    return (update(medications)
      ..where(
            (medication) =>
        medication.id.equals(id) &
        medication.deletedAt.isNull(),
      ))
        .write(
      MedicationsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}