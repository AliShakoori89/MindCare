import 'package:drift/drift.dart';
import '../Tables/sync_cursors.dart';
import '../app_database.dart';
part 'sync_cursor_dao.g.dart';

@DriftAccessor(tables: [SyncCursors])
class SyncCursorDao extends DatabaseAccessor<AppDatabase>
    with _$SyncCursorDaoMixin {
  SyncCursorDao(super.db);

  Future<SyncCursor?> getByUserId(String userId) {
    return (select(syncCursors)
      ..where((cursor) => cursor.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> insertCursor(SyncCursorsCompanion cursor) {
    return into(syncCursors).insert(cursor);
  }

  Future<bool> updateCursor(SyncCursorsCompanion cursor) {
    return update(syncCursors).replace(cursor);
  }

  Future<void> upsertCursor(SyncCursorsCompanion cursor) {
    return into(syncCursors).insertOnConflictUpdate(cursor);
  }
}