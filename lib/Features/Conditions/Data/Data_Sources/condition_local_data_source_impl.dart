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
          payload: jsonEncode({
            'userId': condition.userId.value,
            'name': condition.name.value,
            'status': condition.status.value,
            'diagnosedAt': condition.diagnosedAt.value?.toIso8601String(),
            'diagnosedBy': condition.diagnosedBy.value,
            'notes': condition.notes.value,
          }),
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
  Future<bool> updateCondition(ConditionsCompanion condition) async {
    return _db.transaction(() async {
      final updated = await _db.conditionsDao.updateCondition(condition);

      if (!updated) {
        return false;
      }

      await _db.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: const Uuid().v4(),
          userId: Value(condition.userId.value),
          entityType: 'condition',
          entityId: condition.id.value,
          operation: 'update',
          payload: jsonEncode({
            'userId': condition.userId.value,
            'name': condition.name.value,
            'status': condition.status.value,
            'diagnosedAt': condition.diagnosedAt.value?.toIso8601String(),
            'diagnosedBy': condition.diagnosedBy.value,
            'notes': condition.notes.value,
          }),
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      return true;
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
