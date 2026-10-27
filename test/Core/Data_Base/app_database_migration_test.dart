import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  test('migrates sync_cursors from schema version 2 to 3', () async {
    final executor = NativeDatabase.memory(
      setup: (database) async {
        database.execute('''
      CREATE TABLE sync_cursors (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        cursor TEXT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

        database.execute('''
      INSERT INTO sync_cursors (
        id,
        user_id,
        cursor,
        updated_at
      )
      VALUES (
        'cursor-old',
        'user-1',
        'old-cursor',
        1000
      )
    ''');

        database.execute('''
  INSERT INTO sync_cursors (
    id,
    user_id,
    cursor,
    updated_at
  )
  VALUES (
    'cursor-new',
    'user-1',
    'new-cursor',
    2000
  )
''');

        database.execute('''
  CREATE TABLE outbox (
    id TEXT NOT NULL PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    payload TEXT NOT NULL,
    status TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    last_error TEXT NULL,
    created_at INTEGER NOT NULL
  )
''');

        database.execute('PRAGMA user_version = 2');
      },
    );

    final database = AppDatabase.forTesting(executor);

    final cursor = await database.syncCursorDao.getByUserId('user-1');

    expect(cursor, isNotNull);
    expect(cursor!.id, 'cursor-new');
    expect(cursor.cursor, 'new-cursor');

    await database.close();
  });
}
