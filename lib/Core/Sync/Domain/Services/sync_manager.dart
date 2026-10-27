import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:uuid/uuid.dart';

import '../../../../Features/Conditions/Data/Models/condition_model.dart';

import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_remote_data_source.dart';

import 'dart:convert';

class SyncManager {
  final AppDatabase _db;
  final SyncRemoteDataSource _remoteDataSource;
  final GetCurrentSession _getCurrentSession;
  final ConditionRemoteDataSource _conditionRemoteDataSource;

  SyncManager({
    required this._db,
    required this._remoteDataSource,
    required this._getCurrentSession,
    required this._conditionRemoteDataSource,
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
        if (change.entity != 'condition') {
          throw UnsupportedError('Unsupported sync entity: ${change.entity}');
        }

        switch (change.operation) {
          case 'created':
          case 'updated':
            final data = change.data;
            if (data == null) {
              throw FormatException('Missing data for condition ${change.id}.');
            }

            final model = ConditionModel.fromJson(data);

            if (model.id != change.id) {
              throw FormatException(
                'Condition ID does not match sync change ID.',
              );
            }

            if (model.userId != session.userId) {
              throw FormatException('Condition belongs to a different user.');
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

    // اگر ارسال یک رویداد شکست خورد، رویدادهای بعدی همان
    // Condition را تا تلاش بعدی ارسال نکن.
    final blockedEntities = <String>{};

    for (final entry in entries) {
      final entityKey = '${entry.entityType}:${entry.entityId}';

      if (blockedEntities.contains(entityKey)) {
        continue;
      }

      try {
        if (entry.entityType != 'condition') {
          throw UnsupportedError(
            'Unsupported sync entity: ${entry.entityType}',
          );
        }

        // رکورد باید در دیتابیس محلی وجود داشته باشد؛
        // حتی اگر به‌صورت Soft Delete حذف شده باشد.
        final localCondition = await _db.conditionsDao
            .getConditionByIdIncludingDeleted(entry.entityId);

        if (localCondition == null) {
          throw StateError('Local condition ${entry.entityId} does not exist.');
        }

        if (localCondition.userId != session.userId) {
          throw StateError('Condition belongs to a different user.');
        }

        switch (entry.operation) {
          case 'create':
          case 'update':
            final decoded = jsonDecode(entry.payload);

            if (decoded is! Map) {
              throw const FormatException(
                'Outbox payload must be a JSON object.',
              );
            }

            final payload = Map<String, dynamic>.from(decoded);

            if (payload['userId'] != session.userId) {
              throw StateError('Outbox payload belongs to a different user.');
            }

            final name = payload['name'];
            final status = payload['status'];

            if (name is! String || name.trim().isEmpty) {
              throw const FormatException('Missing or invalid condition name.');
            }

            if (status is! String || status.trim().isEmpty) {
              throw const FormatException(
                'Missing or invalid condition status.',
              );
            }

            final rawDiagnosedAt = payload['diagnosedAt'];
            DateTime? diagnosedAt;

            if (rawDiagnosedAt != null) {
              if (rawDiagnosedAt is! String) {
                throw const FormatException('Invalid diagnosedAt value.');
              }

              diagnosedAt = DateTime.tryParse(rawDiagnosedAt);

              if (diagnosedAt == null) {
                throw const FormatException('Invalid diagnosedAt date.');
              }
            }

            final diagnosedBy = payload['diagnosedBy'];
            final notes = payload['notes'];

            if (diagnosedBy != null && diagnosedBy is! String) {
              throw const FormatException('Invalid diagnosedBy value.');
            }

            if (notes != null && notes is! String) {
              throw const FormatException('Invalid notes value.');
            }

            if (entry.operation == 'create') {
              await _conditionRemoteDataSource.createCondition(
                id: entry.entityId,
                name: name,
                status: status,
                diagnosedAt: diagnosedAt,
                diagnosedBy: diagnosedBy as String?,
                notes: notes as String?,
              );
            } else {
              await _conditionRemoteDataSource.updateCondition(
                id: entry.entityId,
                name: name,
                status: status,
                diagnosedAt: diagnosedAt,
                diagnosedBy: diagnosedBy as String?,
                notes: notes as String?,
              );
            }

          case 'delete':
            final decoded = jsonDecode(entry.payload);

            if (decoded is! Map) {
              throw const FormatException(
                'Outbox payload must be a JSON object.',
              );
            }

            final payload = Map<String, dynamic>.from(decoded);

            if (payload['userId'] != session.userId) {
              throw StateError(
                'Outbox payload belongs to a different user.',
              );
            }

            await _conditionRemoteDataSource.deleteCondition(entry.entityId);

          default:
            throw UnsupportedError(
              'Unsupported sync operation: ${entry.operation}',
            );
        }

        // فقط پس از موفقیت عملیات Remote، رویداد را حذف کن.
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
}
