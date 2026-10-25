import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:uuid/uuid.dart';
import '../../../../Features/Conditions/Data/Models/condition_model.dart';

class SyncManager {
  final AppDatabase _db;
  final SyncRemoteDataSource _remoteDataSource;
  final GetCurrentSession _getCurrentSession;

  SyncManager({
    required this._db,
    required this._remoteDataSource,
    required this._getCurrentSession,
  });

  Future<void> pullChanges() async {
    final session = await _getCurrentSession();

    if (session == null) {
      throw StateError('Cannot sync without an authenticated session.');
    }

    final savedCursor = await _db.syncCursorDao.getByUserId(
      session.userId,
    );

    final response = await _remoteDataSource.getChanges(
      cursor: savedCursor?.cursor,
    );

    await _db.transaction(() async {
      for (final change in response.changes) {
        if (change.entity != 'condition') {
          throw UnsupportedError(
            'Unsupported sync entity: ${change.entity}',
          );
        }

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
}
