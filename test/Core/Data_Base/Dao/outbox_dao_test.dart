import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/outbox_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late OutboxDao outboxDao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    outboxDao = OutboxDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  final now = DateTime(2026, 10, 21, 10);

  OutboxCompanion createEntry({
    String id = 'outbox-1',
    String? userId = 'user-1',
    String entityType = 'condition',
    String entityId = 'condition-1',
    String operation = 'create',
    String payload = '{"name":"Diabetes"}',
    String status = 'pending',
    int attempts = 0,
    String? lastError,
    DateTime? createdAt,
  }) {
    return OutboxCompanion.insert(
      id: id,
      userId: drift.Value(userId),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      status: status,
      attempts: drift.Value(attempts),
      lastError: drift.Value(lastError),
      createdAt: createdAt ?? now,
    );
  }

  test('insertOutbox and getById should work', () async {
    await outboxDao.insertOutbox(createEntry());

    final entry = await outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.id, 'outbox-1');
    expect(entry.entityType, 'condition');
    expect(entry.entityId, 'condition-1');
    expect(entry.operation, 'create');
    expect(entry.payload, '{"name":"Diabetes"}');
    expect(entry.status, 'pending');
    expect(entry.attempts, 0);
    expect(entry.lastError, isNull);
  });

  test('getById should return null when entry does not exist', () async {
    final entry = await outboxDao.getById('missing');

    expect(entry, isNull);
  });

  test('getPendingEntries should return only pending entries for the requested user in order', () async {
    await outboxDao.insertOutbox(
      createEntry(
        id: 'later',
        userId: 'user-1',
        createdAt: DateTime(2026, 10, 21, 12),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'failed',
        userId: 'user-1',
        status: 'failed',
        createdAt: DateTime(2026, 10, 21, 9),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'earlier',
        userId: 'user-1',
        createdAt: DateTime(2026, 10, 21, 8),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'processing',
        userId: 'user-1',
        status: 'processing',
        createdAt: DateTime(2026, 10, 21, 7),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'other-user',
        userId: 'user-2',
        createdAt: DateTime(2026, 10, 21, 6),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'legacy-null-user',
        userId: null,
        createdAt: DateTime(2026, 10, 21, 5),
      ),
    );

    final entries = await outboxDao.getPendingEntries(userId: 'user-1');

    expect(entries.map((entry) => entry.id).toList(), ['earlier', 'later']);
  });

  test('updateOutbox should update an existing entry', () async {
    await outboxDao.insertOutbox(createEntry());

    final result = await outboxDao.updateOutbox(
      createEntry(
        payload: '{"name":"Updated Diabetes"}',
        status: 'failed',
        attempts: 2,
        lastError: 'Network error',
      ),
    );

    expect(result, isTrue);

    final entry = await outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.payload, '{"name":"Updated Diabetes"}');
    expect(entry.status, 'failed');
    expect(entry.attempts, 2);
    expect(entry.lastError, 'Network error');
  });

  test('deleteById should delete the matching entry', () async {
    await outboxDao.insertOutbox(createEntry());

    final deletedRows = await outboxDao.deleteById('outbox-1');

    expect(deletedRows, 1);
    expect(await outboxDao.getById('outbox-1'), isNull);
  });

  test('deleteByEntity should delete only matching entity entries', () async {
    await outboxDao.insertOutbox(createEntry(id: 'condition-1-a'));

    await outboxDao.insertOutbox(
      createEntry(id: 'condition-1-b', operation: 'update'),
    );

    await outboxDao.insertOutbox(
      createEntry(id: 'condition-2', entityId: 'condition-2'),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'journal-1',
        entityType: 'journal',
        entityId: 'condition-1',
      ),
    );

    final deletedRows = await outboxDao.deleteByEntity(
      entityType: 'condition',
      entityId: 'condition-1',
    );

    expect(deletedRows, 2);
    expect(await outboxDao.getById('condition-1-a'), isNull);
    expect(await outboxDao.getById('condition-1-b'), isNull);
    expect(await outboxDao.getById('condition-2'), isNotNull);
    expect(await outboxDao.getById('journal-1'), isNotNull);
  });
}
