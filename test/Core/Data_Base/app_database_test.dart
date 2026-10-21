import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates all 13 tables', () async {
    final tables = await database.customSelect(
      '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    AND name NOT LIKE 'sqlite_%'
    ORDER BY name
    ''',
    ).get();

    final tableNames = tables
        .map((row) => row.read<String>('name'))
        .toList();

    expect(
      tableNames,
      containsAll([
        'users',
        'patient_profiles',
        'conditions',
        'medications',
        'daily_check_ins',
        'journal_entries',
        'medical_documents',
        'timeline_events',
        'insights',
        'conversations',
        'messages',
        'outbox',
        'sync_cursors',
      ]),
    );

    expect(tableNames.length, 13);
  });

  test('sync_cursors enforces unique user_id', () async {
    await database.into(database.syncCursors).insert(
      SyncCursorsCompanion.insert(
        id: 'cursor-1',
        userId: 'user-1',
        updatedAt: DateTime(2026, 10, 21),
      ),
    );

    expect(
          () => database.into(database.syncCursors).insert(
        SyncCursorsCompanion.insert(
          id: 'cursor-2',
          userId: 'user-1',
          updatedAt: DateTime(2026, 10, 21),
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });
}