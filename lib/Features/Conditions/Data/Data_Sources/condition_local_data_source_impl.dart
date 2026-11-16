import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:uuid/uuid.dart';

import 'condition_local_data_source.dart';

class ConditionLocalDataSourceImpl implements ConditionLocalDataSource {
  final AppDatabase _db;

  ConditionLocalDataSourceImpl(this._db);

  @override
  Future<void> insertCondition(ConditionsCompanion condition) {
    return _db.transaction(() async {
      await _db.conditionsDao.insertCondition(condition);

      await _db.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: const Uuid().v4(),
          userId: Value(condition.userId.value),
          entityType: 'condition',
          entityId: condition.id.value,
          operation: 'create',
          payload: _buildPayload(condition),
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Future<Condition?> getConditionById(String id) {
    return _db.conditionsDao.getConditionById(id);
  }

  @override
  Future<List<Condition>> getConditionsByUserId(String userId) {
    return _db.conditionsDao.getConditionsByUserId(userId);
  }

  @override
  Future<bool> updateCondition(ConditionsCompanion condition) {
    return _db.transaction(() async {
      final id = condition.id.value;
      final userId = condition.userId.value;

      // Read the current local record before updating it.
      final existing = await _db.conditionsDao.getConditionByIdIncludingDeleted(
        id,
      );

      if (existing == null ||
          existing.userId != userId ||
          existing.deletedAt != null) {
        return false;
      }

      // Find an existing pending/conflict operation for this entity.
      final existingOperation = await _db.outboxDao.getOperationForEntity(
        userId: userId,
        entityType: 'condition',
        entityId: id,
      );

      // A queued delete must not be replaced by an update.
      if (existingOperation?.operation == 'delete') {
        throw StateError(
          'Cannot update a condition while a delete operation is pending or conflicted.',
        );
      }

      // Preserve the current server version.
      final updatedCondition = condition.copyWith(
        version: Value(existing.version),
      );

      final updated = await _db.conditionsDao.updateCondition(updatedCondition);

      if (!updated) {
        return false;
      }

      final payload = _buildPayload(updatedCondition);

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
            entityType: 'condition',
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

  String _buildPayload(ConditionsCompanion condition) {
    return jsonEncode({
      'userId': condition.userId.value,
      'name': condition.name.value,
      'status': condition.status.value,
      'diagnosedAt': condition.diagnosedAt.value?.toIso8601String(),
      'diagnosedBy': condition.diagnosedBy.value,
      'notes': condition.notes.value,
    });
  }

  @override
  Future<int> deleteCondition(String id) async {
    return _db.transaction(() async {
      final condition = await _db.conditionsDao
          .getConditionByIdIncludingDeleted(id);

      if (condition == null || condition.deletedAt != null) {
        return 0;
      }

      final deleted = await _db.conditionsDao.deleteCondition(
        id: id,
        userId: condition.userId,
      );

      if (deleted == 0) return 0;

      await _db.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: const Uuid().v4(),
          userId: Value(condition.userId),
          entityType: 'condition',
          entityId: id,
          operation: 'delete',
          payload: jsonEncode({'userId': condition.userId}),
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      return deleted;
    });
  }
}
