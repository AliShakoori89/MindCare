import 'dart:convert';

import 'package:mind_care/Core/Sync/Domain/Entities/conflict_entry.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Domain/Repositories/conflict_repository.dart';
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:mind_care/Features/Conditions/Data/Models/condition_model.dart';
import 'package:mind_care/Features/Medications/Data/Mappers/medication_mapper.dart';
import 'package:mind_care/Features/Medications/Data/Models/medication_model.dart';

class ConflictRepositoryImpl implements ConflictRepository {
  final AppDatabase _db;

  ConflictRepositoryImpl(this._db);

  @override
  Future<List<ConflictEntry>> getConflicts({required String userId}) async {
    final entries = await _db.outboxDao.getConflictEntries(userId: userId);

    return entries
        .map(
          (entry) => ConflictEntry(
            outboxId: entry.id,
            entityType: entry.entityType,
            entityId: entry.entityId,
            operation: entry.operation,
            payload: entry.payload,
            baseVersion: entry.baseVersion,
            conflictPayload: entry.conflictPayload!,
            createdAt: entry.createdAt,
            lastError: entry.lastError,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> keepLocal({required String outboxId, required String userId}) {
    return _db.transaction(() async {
      final entry = await _getValidatedConflict(
        outboxId: outboxId,
        userId: userId,
      );

      final payload = _decodeConflictPayload(entry.conflictPayload!);
      final currentVersion = _readCurrentVersion(payload);

      final updatedCount = await _db.outboxDao.resolveKeepLocal(
        id: entry.id,
        currentVersion: currentVersion,
      );

      if (updatedCount != 1) {
        throw StateError(
          'Could not resolve conflict for Outbox entry: ${entry.id}',
        );
      }
    });
  }

  @override
  Future<void> acceptServer({
    required String outboxId,
    required String userId,
  }) {
    return _db.transaction(() async {
      final entry = await _getValidatedConflict(
        outboxId: outboxId,
        userId: userId,
      );

      final payload = _decodeConflictPayload(entry.conflictPayload!);
      final currentVersion = _readCurrentVersion(payload);
      final rawCurrentData = payload['currentData'];

      if (rawCurrentData is! Map) {
        throw const FormatException(
          'Conflict response does not contain valid currentData.',
        );
      }

      final currentData = Map<String, dynamic>.from(rawCurrentData);

      switch (entry.entityType) {
        case 'condition':
          final model = ConditionModel.fromJson(currentData);

          _validateServerSnapshot(
            id: model.id,
            userId: model.userId,
            version: model.version,
            expectedId: entry.entityId,
            expectedUserId: userId,
            expectedVersion: currentVersion,
          );

          await _db.conditionsDao.applyRemoteCondition(
            ConditionMapper.modelToCompanion(model),
          );

        case 'medication':
          final model = MedicationModel.fromJson(currentData);

          _validateServerSnapshot(
            id: model.id,
            userId: model.userId,
            version: model.version,
            expectedId: entry.entityId,
            expectedUserId: userId,
            expectedVersion: currentVersion,
          );

          await _db.medicationsDao.applyRemoteMedication(
            MedicationMapper.modelToCompanion(model),
          );

        default:
          throw UnsupportedError(
            'Unsupported conflict entity type: ${entry.entityType}',
          );
      }

      final deletedCount = await _db.outboxDao.deleteById(entry.id);

      if (deletedCount != 1) {
        throw StateError('Could not delete resolved Outbox entry: ${entry.id}');
      }
    });
  }

  Future<OutboxData> _getValidatedConflict({
    required String outboxId,
    required String userId,
  }) async {
    final entry = await _db.outboxDao.getById(outboxId);

    if (entry == null) {
      throw StateError('Outbox entry not found: $outboxId');
    }

    if (entry.userId != userId) {
      throw StateError('Outbox entry does not belong to the requested user.');
    }

    if (entry.status != 'conflict') {
      throw StateError(
        'Outbox entry is not in conflict state: ${entry.status}',
      );
    }

    if (entry.operation != 'update') {
      throw UnsupportedError('Only update conflicts can be resolved manually.');
    }

    if (entry.entityType != 'condition' && entry.entityType != 'medication') {
      throw UnsupportedError(
        'Unsupported conflict entity type: ${entry.entityType}',
      );
    }

    if (entry.conflictPayload == null || entry.conflictPayload!.isEmpty) {
      throw const FormatException('Conflict payload is missing.');
    }

    return entry;
  }

  Map<String, dynamic> _decodeConflictPayload(String rawPayload) {
    final decoded = jsonDecode(rawPayload);

    if (decoded is! Map) {
      throw const FormatException('Conflict payload must be a JSON object.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  int _readCurrentVersion(Map<String, dynamic> payload) {
    final version = payload['currentVersion'];

    if (version is! int || version < 1) {
      throw const FormatException(
        'Conflict payload contains an invalid currentVersion.',
      );
    }

    return version;
  }

  void _validateServerSnapshot({
    required String id,
    required String userId,
    required int version,
    required String expectedId,
    required String expectedUserId,
    required int expectedVersion,
  }) {
    if (id != expectedId) {
      throw const FormatException(
        'Server snapshot entity ID does not match Outbox entry.',
      );
    }

    if (userId != expectedUserId) {
      throw const FormatException(
        'Server snapshot user ID does not match the requested user.',
      );
    }

    if (version != expectedVersion) {
      throw const FormatException(
        'Server snapshot version does not match currentVersion.',
      );
    }
  }
}
