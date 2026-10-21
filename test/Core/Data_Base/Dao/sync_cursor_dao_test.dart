
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/sync_cursor_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late SyncCursorDao syncCursorDao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncCursorDao = SyncCursorDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  final now = DateTime(2026, 10, 21, 10);

  SyncCursorsCompanion createCursor({
    required String id,
    required String userId,
    String? cursor,
    DateTime? updatedAt,
  }) {
    return SyncCursorsCompanion.insert(
      id: id,
      userId: userId,
      cursor: drift.Value(cursor),
      updatedAt: updatedAt ?? now,
    );
  }

  test('getByUserId should return null when cursor does not exist',
          () async {
        final result = await syncCursorDao.getByUserId('user-1');

        expect(result, isNull);
      });

  test('insertCursor and getByUserId should work', () async {
    await syncCursorDao.insertCursor(
      createCursor(
        id: 'cursor-1',
        userId: 'user-1',
        cursor: '2026-10-21T09:00:00.000Z',
      ),
    );

    final result = await syncCursorDao.getByUserId('user-1');

    expect(result, isNotNull);
    expect(result!.id, 'cursor-1');
    expect(result.userId, 'user-1');
    expect(result.cursor, '2026-10-21T09:00:00.000Z');
  });

  test('cursor may be null before the first successful sync', () async {
    await syncCursorDao.insertCursor(
      createCursor(
        id: 'cursor-1',
        userId: 'user-1',
      ),
    );

    final result = await syncCursorDao.getByUserId('user-1');

    expect(result, isNotNull);
    expect(result!.cursor, isNull);
  });

  test('upsertCursor should update an existing record with the same id',
          () async {
        await syncCursorDao.insertCursor(
          createCursor(
            id: 'cursor-1',
            userId: 'user-1',
            cursor: '2026-10-21T09:00:00.000Z',
          ),
        );

        final updatedAt = DateTime(2026, 10, 21, 11);

        await syncCursorDao.upsertCursor(
          createCursor(
            id: 'cursor-1',
            userId: 'user-1',
            cursor: '2026-10-21T10:00:00.000Z',
            updatedAt: updatedAt,
          ),
        );

        final result = await syncCursorDao.getByUserId('user-1');

        expect(result, isNotNull);
        expect(result!.cursor, '2026-10-21T10:00:00.000Z');
        expect(result.updatedAt, updatedAt);
      });

  test('upsertCursor should insert a new record when id is new', () async {
    await syncCursorDao.upsertCursor(
      createCursor(
        id: 'cursor-1',
        userId: 'user-1',
        cursor: '2026-10-21T09:00:00.000Z',
      ),
    );

    await syncCursorDao.upsertCursor(
      createCursor(
        id: 'cursor-2',
        userId: 'user-2',
        cursor: '2026-10-21T10:00:00.000Z',
      ),
    );

    expect(await syncCursorDao.getByUserId('user-1'), isNotNull);
    expect(await syncCursorDao.getByUserId('user-2'), isNotNull);

    expect(
      (await syncCursorDao.getByUserId('user-1'))!.cursor,
      '2026-10-21T09:00:00.000Z',
    );

    expect(
      (await syncCursorDao.getByUserId('user-2'))!.cursor,
      '2026-10-21T10:00:00.000Z',
    );
  });

  test('updateCursor should update an existing record', () async {
    await syncCursorDao.insertCursor(
      createCursor(
        id: 'cursor-1',
        userId: 'user-1',
        cursor: '2026-10-21T09:00:00.000Z',
      ),
    );

    final result = await syncCursorDao.updateCursor(
      createCursor(
        id: 'cursor-1',
        userId: 'user-1',
        cursor: '2026-10-21T10:00:00.000Z',
      ),
    );

    expect(result, isTrue);

    final cursor = await syncCursorDao.getByUserId('user-1');

    expect(cursor!.cursor, '2026-10-21T10:00:00.000Z');
  });
}
