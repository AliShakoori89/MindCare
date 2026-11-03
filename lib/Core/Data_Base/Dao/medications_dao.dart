
import 'package:drift/drift.dart';

import '../Tables/medications.dart';
import '../app_database.dart';

part 'medications_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  Future<void> insertMedication(MedicationsCompanion medication) {
    return into(medications).insert(medication);
  }

  // Insert or update medication received from remote server.
  Future<void> applyRemoteMedication(MedicationsCompanion medication) {
    return into(medications).insertOnConflictUpdate(medication);
  }

  Future<Medication?> getMedicationById(String id) {
    return (select(medications)
      ..where((medication) =>
      medication.id.equals(id) &
      medication.deletedAt.isNull()))
        .getSingleOrNull();
  }

  // Includes soft-deleted medications.
  Future<Medication?> getMedicationByIdIncludingDeleted(String id) {
    return (select(medications)
      ..where((medication) => medication.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Medication>> getMedicationsByUserId(String userId) {
    return (select(medications)
      ..where((medication) =>
      medication.userId.equals(userId) &
      medication.deletedAt.isNull()))
        .get();
  }

  Future<bool> updateMedication(MedicationsCompanion medication) {
    return update(medications).replace(medication);
  }

  // Local soft delete with user ownership validation.
  Future<int> deleteMedication({
    required String id,
    required String userId,
  }) {
    final now = DateTime.now();

    return (update(medications)
      ..where((medication) =>
      medication.id.equals(id) &
      medication.userId.equals(userId) &
      medication.deletedAt.isNull()))
        .write(
      MedicationsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  // Apply remote deletion without creating another Outbox event.
  Future<int> applyRemoteDeleteMedication({
    required String id,
    required String userId,
    required DateTime deletedAt,
  }) {
    return (update(medications)
      ..where((medication) =>
      medication.id.equals(id) &
      medication.userId.equals(userId)))
        .write(
      MedicationsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }
}
