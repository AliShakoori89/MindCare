import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:uuid/uuid.dart';

import '../../../../Features/Conditions/Data/Models/condition_model.dart';

import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_remote_data_source.dart';

import 'dart:convert';

import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_remote_data_source.dart';
import 'package:mind_care/Features/Medications/Data/Models/medication_model.dart';
import 'package:mind_care/Features/Medications/Data/Mappers/medication_mapper.dart';

class SyncManager {
  final AppDatabase _db;
  final SyncRemoteDataSource _remoteDataSource;
  final GetCurrentSession _getCurrentSession;
  final ConditionRemoteDataSource _conditionRemoteDataSource;
  final MedicationRemoteDataSource _medicationRemoteDataSource;

  SyncManager({
    required this._db,
    required this._remoteDataSource,
    required this._getCurrentSession,
    required this._conditionRemoteDataSource,
    required this._medicationRemoteDataSource,
  });


  Future<void> pullChanges() async {
    final session = await _getCurrentSession();

    if (session == null) {
      throw StateError('Cannot sync without an authenticated session.');
    }

    final savedCursor = await _db.syncCursorDao.getByUserId(session.userId);

    final response = await _remoteDataSource.getChanges(
      cursor: savedCursor?.cursor,
    );

    await _db.transaction(() async {
      for (final change in response.changes) {
        final hasPendingOperation =
        await _db.outboxDao.hasPendingOperation(
          userId: session.userId,
          entityType: change.entity,
          entityId: change.id,
        );

        if (hasPendingOperation) {
          continue;
        }

        switch (change.entity) {
          case 'condition':
            switch (change.operation) {
              case 'created':
              case 'updated':
                final data = change.data;

                if (data == null) {
                  throw FormatException(
                    'Missing data for condition ${change.id}.',
                  );
                }

                final model = ConditionModel.fromJson(data);

                if (model.id != change.id) {
                  throw FormatException(
                    'Condition ID does not match sync change ID.',
                  );
                }

                if (model.userId != session.userId) {
                  throw FormatException(
                    'Condition belongs to a different user.',
                  );
                }

                await _db.conditionsDao.applyRemoteCondition(
                  ConditionMapper.modelToCompanion(model),
                );

              case 'deleted':
                await _db.conditionsDao.applyRemoteDeleteCondition(
                  id: change.id,
                  userId: session.userId,
                  deletedAt: change.timestamp,
                );

              default:
                throw UnsupportedError(
                  'Unsupported sync operation: ${change.operation}',
                );
            }

          case 'medication':
            switch (change.operation) {
              case 'created':
              case 'updated':
                final data = change.data;

                if (data == null) {
                  throw FormatException(
                    'Missing data for medication ${change.id}.',
                  );
                }

                final model = MedicationModel.fromJson(data);

                if (model.id != change.id) {
                  throw FormatException(
                    'Medication ID does not match sync change ID.',
                  );
                }

                if (model.userId != session.userId) {
                  throw FormatException(
                    'Medication belongs to a different user.',
                  );
                }

                await _db.medicationsDao.applyRemoteMedication(
                  MedicationMapper.modelToCompanion(model),
                );

              case 'deleted':
                await _db.medicationsDao.applyRemoteDeleteMedication(
                  id: change.id,
                  userId: session.userId,
                  deletedAt: change.timestamp,
                );

              default:
                throw UnsupportedError(
                  'Unsupported sync operation: ${change.operation}',
                );
            }

          default:
            throw UnsupportedError(
              'Unsupported sync entity: ${change.entity}',
            );
        }
      }

      await _db.syncCursorDao.upsertCursor(
        SyncCursorsCompanion.insert(
          id: savedCursor?.id ?? const Uuid().v4(),
          userId: session.userId,
          cursor: Value(response.cursor),
          updatedAt: DateTime.now(),
        ),
      );
    });
  }


  Future<void> pushChanges() async {
    final session = await _getCurrentSession();

    if (session == null) {
      throw StateError('Cannot sync without an authenticated session.');
    }

    final entries = await _db.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    final blockedEntities = <String>{};

    for (final entry in entries) {
      final entityKey = '${entry.entityType}:${entry.entityId}';

      if (blockedEntities.contains(entityKey)) {
        continue;
      }

      try {
        switch (entry.entityType) {
          case 'condition':
            await _pushConditionEntry(
              entry: entry,
              userId: session.userId,
            );

          case 'medication':
            await _pushMedicationEntry(
              entry: entry,
              userId: session.userId,
            );

          default:
            throw UnsupportedError(
              'Unsupported sync entity: ${entry.entityType}',
            );
        }

        await _db.outboxDao.deleteById(entry.id);
      } catch (error) {
        blockedEntities.add(entityKey);

        await _db.outboxDao.markAsFailed(
          id: entry.id,
          attempts: entry.attempts + 1,
          error: error.toString(),
        );
      }
    }
  }

  Future<void> _pushConditionEntry({
    required OutboxData entry,
    required String userId,
  }) async {
    final localCondition = await _db.conditionsDao
        .getConditionByIdIncludingDeleted(entry.entityId);

    if (localCondition == null) {
      throw StateError(
        'Local condition ${entry.entityId} does not exist.',
      );
    }

    if (localCondition.userId != userId) {
      throw StateError('Condition belongs to a different user.');
    }

    switch (entry.operation) {
      case 'create':
      case 'update':
        final payload = _decodePayload(entry.payload);

        _validatePayloadUser(payload, userId);

        final name = payload['name'];
        final status = payload['status'];

        if (name is! String || name.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid condition name.',
          );
        }

        if (status is! String || status.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid condition status.',
          );
        }

        final diagnosedAt = _parseOptionalDate(
          payload['diagnosedAt'],
          'diagnosedAt',
        );

        final diagnosedBy = _optionalString(
          payload['diagnosedBy'],
          'diagnosedBy',
        );

        final notes = _optionalString(
          payload['notes'],
          'notes',
        );

        if (entry.operation == 'create') {
          await _conditionRemoteDataSource.createCondition(
            id: entry.entityId,
            name: name,
            status: status,
            diagnosedAt: diagnosedAt,
            diagnosedBy: diagnosedBy,
            notes: notes,
          );
        } else {
          await _conditionRemoteDataSource.updateCondition(
            id: entry.entityId,
            name: name,
            status: status,
            diagnosedAt: diagnosedAt,
            diagnosedBy: diagnosedBy,
            notes: notes,
          );
        }

      case 'delete':
        final payload = _decodePayload(entry.payload);

        _validatePayloadUser(payload, userId);

        await _conditionRemoteDataSource.deleteCondition(
          entry.entityId,
        );

      default:
        throw UnsupportedError(
          'Unsupported sync operation: ${entry.operation}',
        );
    }
  }

  Map<String, dynamic> _decodePayload(String rawPayload) {
    final decoded = jsonDecode(rawPayload);

    if (decoded is! Map) {
      throw const FormatException(
        'Outbox payload must be a JSON object.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  void _validatePayloadUser(
      Map<String, dynamic> payload,
      String userId,
      ) {
    if (payload['userId'] != userId) {
      throw StateError(
        'Outbox payload belongs to a different user.',
      );
    }
  }

  String? _optionalString(
      dynamic value,
      String fieldName,
      ) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw FormatException(
        'Invalid $fieldName value.',
      );
    }

    return value;
  }

  DateTime? _parseOptionalDate(
      dynamic value,
      String fieldName,
      ) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw FormatException(
        'Invalid $fieldName value.',
      );
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      throw FormatException(
        'Invalid $fieldName date.',
      );
    }

    return date;
  }

  Future<void> _pushMedicationEntry({
    required OutboxData entry,
    required String userId,
  }) async {
    final localMedication = await _db.medicationsDao
        .getMedicationByIdIncludingDeleted(entry.entityId);

    if (localMedication == null) {
      throw StateError(
        'Local medication ${entry.entityId} does not exist.',
      );
    }

    if (localMedication.userId != userId) {
      throw StateError('Medication belongs to a different user.');
    }

    switch (entry.operation) {
      case 'create':
      case 'update':
        final payload = _decodePayload(entry.payload);

        _validatePayloadUser(payload, userId);

        final name = payload['name'];
        final frequencyType = payload['frequencyType'];
        final route = payload['route'];
        final status = payload['status'];

        if (name is! String || name.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid medication name.',
          );
        }

        if (frequencyType is! String ||
            frequencyType.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid medication frequencyType.',
          );
        }

        if (route is! String || route.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid medication route.',
          );
        }

        if (status is! String || status.trim().isEmpty) {
          throw const FormatException(
            'Missing or invalid medication status.',
          );
        }

        final genericName = _optionalString(
          payload['genericName'],
          'genericName',
        );

        final dosage = _optionalString(
          payload['dosage'],
          'dosage',
        );

        final unit = _optionalString(
          payload['unit'],
          'unit',
        );

        final frequencyValue = _optionalString(
          payload['frequencyValue'],
          'frequencyValue',
        );

        final prescribedBy = _optionalString(
          payload['prescribedBy'],
          'prescribedBy',
        );

        final notes = _optionalString(
          payload['notes'],
          'notes',
        );

        final startDate = _parseOptionalDate(
          payload['startDate'],
          'startDate',
        );

        final endDate = _parseOptionalDate(
          payload['endDate'],
          'endDate',
        );

        if (entry.operation == 'create') {
          await _medicationRemoteDataSource.createMedication(
            id: entry.entityId,
            name: name,
            genericName: genericName,
            dosage: dosage,
            unit: unit,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            route: route,
            startDate: startDate,
            endDate: endDate,
            status: status,
            prescribedBy: prescribedBy,
            notes: notes,
          );
        } else {
          await _medicationRemoteDataSource.updateMedication(
            id: entry.entityId,
            name: name,
            genericName: genericName,
            dosage: dosage,
            unit: unit,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            route: route,
            startDate: startDate,
            endDate: endDate,
            status: status,
            prescribedBy: prescribedBy,
            notes: notes,
          );
        }

      case 'delete':
        final payload = _decodePayload(entry.payload);

        _validatePayloadUser(payload, userId);

        await _medicationRemoteDataSource.deleteMedication(
          entry.entityId,
        );

      default:
        throw UnsupportedError(
          'Unsupported sync operation: ${entry.operation}',
        );
    }
  }

}
