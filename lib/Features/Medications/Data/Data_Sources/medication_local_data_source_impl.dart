import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:uuid/uuid.dart';

import 'medication_local_data_source.dart';

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final AppDatabase _db;

  MedicationLocalDataSourceImpl(this._db);

  @override
  Future<void> insertMedication(MedicationsCompanion medication) {
    return _db.transaction(() async {
      await _db.medicationsDao.insertMedication(medication);

      await _db.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: const Uuid().v4(),
          userId: Value(medication.userId.value),
          entityType: 'medication',
          entityId: medication.id.value,
          operation: 'create',
          payload: _buildPayload(medication),
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Future<Medication?> getMedicationById(String id) {
    return _db.medicationsDao.getMedicationById(id);
  }

  @override
  Future<List<Medication>> getMedicationsByUserId(String userId) {
    return _db.medicationsDao.getMedicationsByUserId(userId);
  }

  @override
  Future<bool> updateMedication(MedicationsCompanion medication) {
    return _db.transaction(() async {
      final id = medication.id.value;
      final userId = medication.userId.value;

      // Read the current local record before updating it.
      final existing = await _db.medicationsDao
          .getMedicationByIdIncludingDeleted(id);

      if (existing == null ||
          existing.userId != userId ||
          existing.deletedAt != null) {
        return false;
      }

      // Find an existing pending/conflict operation for this entity.
      final existingOperation = await _db.outboxDao.getOperationForEntity(
        userId: userId,
        entityType: 'medication',
        entityId: id,
      );

      // A queued delete must not be replaced by an update.
      if (existingOperation?.operation == 'delete') {
        throw StateError(
          'Cannot update a medication while a delete operation is pending or conflicted.',
        );
      }

      // Preserve the current server version.
      final updatedMedication = medication.copyWith(
        version: Value(existing.version),
      );

      final updated = await _db.medicationsDao.updateMedication(
        updatedMedication,
      );

      if (!updated) {
        return false;
      }

      final payload = _buildPayload(updatedMedication);

      if (existingOperation != null) {
        // Keep the original operation, status, baseVersion and conflict data.
        await _db.outboxDao.updatePayload(
          id: existingOperation.id,
          payload: payload,
        );
      } else {
        // First update for this entity: capture its current version.
        await _db.outboxDao.insertOutbox(
          OutboxCompanion.insert(
            id: const Uuid().v4(),
            userId: Value(userId),
            entityType: 'medication',
            entityId: id,
            operation: 'update',
            payload: payload,
            status: 'pending',
            createdAt: DateTime.now(),
            baseVersion: Value(existing.version),
          ),
        );
      }

      return true;
    });
  }

  String _buildPayload(MedicationsCompanion medication) {
    return jsonEncode({
      'userId': medication.userId.value,
      'name': medication.name.value,
      'genericName': medication.genericName.value,
      'dosage': medication.dosage.value,
      'unit': medication.unit.value,
      'frequencyType': medication.frequencyType.value,
      'frequencyValue': medication.frequencyValue.value,
      'route': medication.route.value,
      'startDate': medication.startDate.value?.toIso8601String(),
      'endDate': medication.endDate.value?.toIso8601String(),
      'status': medication.status.value,
      'prescribedBy': medication.prescribedBy.value,
      'notes': medication.notes.value,
    });
  }

  @override
  Future<int> deleteMedication({
    required String id,
    required String userId,
  }) async {
    return _db.transaction(() async {
      final medication = await _db.medicationsDao
          .getMedicationByIdIncludingDeleted(id);

      if (medication == null ||
          medication.userId != userId ||
          medication.deletedAt != null) {
        return 0;
      }

      final deleted = await _db.medicationsDao.deleteMedication(
        id: id,
        userId: userId,
      );

      if (deleted == 0) {
        return 0;
      }

      await _db.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: const Uuid().v4(),
          userId: Value(userId),
          entityType: 'medication',
          entityId: id,
          operation: 'delete',
          payload: jsonEncode({'userId': userId}),
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      return deleted;
    });
  }
}
