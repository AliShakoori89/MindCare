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
    int? baseVersion,
    String? conflictPayload,
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
      baseVersion: drift.Value(baseVersion),
      conflictPayload: drift.Value(conflictPayload),
    );
  }

  test(
    'getOperationForEntity should return the existing pending operation',
    () async {
      await outboxDao.insertOutbox(
        createEntry(id: 'first', createdAt: DateTime(2026, 10, 21, 8)),
      );

      await outboxDao.insertOutbox(
        createEntry(
          id: 'second',
          operation: 'update',
          createdAt: DateTime(2026, 10, 21, 9),
        ),
      );

      final entry = await outboxDao.getOperationForEntity(
        userId: 'user-1',
        entityType: 'condition',
        entityId: 'condition-1',
      );

      expect(entry, isNotNull);
      expect(entry!.id, 'first');
    },
  );

  test('getOperationForEntity should find conflicted operations', () async {
    await outboxDao.insertOutbox(
      createEntry(
        status: 'conflict',
        operation: 'update',
        baseVersion: 2,
        conflictPayload: '{"version":3}',
      ),
    );

    final entry = await outboxDao.getOperationForEntity(
      userId: 'user-1',
      entityType: 'condition',
      entityId: 'condition-1',
    );

    expect(entry, isNotNull);
    expect(entry!.status, 'conflict');
    expect(entry.baseVersion, 2);
  });

  test(
    'hasPendingOrConflict should return true for conflicted entries',
    () async {
      await outboxDao.insertOutbox(createEntry(status: 'conflict'));

      final result = await outboxDao.hasPendingOrConflict(
        userId: 'user-1',
        entityType: 'condition',
        entityId: 'condition-1',
      );

      expect(result, isTrue);
    },
  );

  test('updatePayload should preserve baseVersion and conflict data', () async {
    await outboxDao.insertOutbox(
      createEntry(
        status: 'conflict',
        operation: 'update',
        baseVersion: 2,
        conflictPayload: '{"version":3}',
      ),
    );

    await outboxDao.updatePayload(
      id: 'outbox-1',
      payload: '{"name":"Updated Diabetes"}',
    );

    final entry = await outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.payload, '{"name":"Updated Diabetes"}');
    expect(entry.status, 'conflict');
    expect(entry.baseVersion, 2);
    expect(entry.conflictPayload, '{"version":3}');
  });

  test(
    'markAsConflict should save server snapshot without incrementing attempts',
    () async {
      await outboxDao.insertOutbox(
        createEntry(attempts: 2, operation: 'update', baseVersion: 1),
      );

      await outboxDao.markAsConflict(
        id: 'outbox-1',
        conflictPayload: '{"version":2,"name":"Server value"}',
        error: 'Condition has been modified by another device',
      );

      final entry = await outboxDao.getById('outbox-1');

      expect(entry, isNotNull);
      expect(entry!.status, 'conflict');
      expect(entry.attempts, 2);
      expect(entry.baseVersion, 1);
      expect(entry.conflictPayload, '{"version":2,"name":"Server value"}');
      expect(entry.lastError, 'Condition has been modified by another device');
    },
  );

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

  test(
    'hasPendingOperation should return true for matching pending entry',
    () async {
      await outboxDao.insertOutbox(createEntry());

      final result = await outboxDao.hasPendingOperation(
        userId: 'user-1',
        entityType: 'condition',
        entityId: 'condition-1',
      );

      expect(result, isTrue);
    },
  );

  test(
    'hasPendingOperation should return false for another user or entity',
    () async {
      await outboxDao.insertOutbox(createEntry());

      final differentUser = await outboxDao.hasPendingOperation(
        userId: 'user-2',
        entityType: 'condition',
        entityId: 'condition-1',
      );

      final differentEntity = await outboxDao.hasPendingOperation(
        userId: 'user-1',
        entityType: 'condition',
        entityId: 'condition-2',
      );

      final differentType = await outboxDao.hasPendingOperation(
        userId: 'user-1',
        entityType: 'medication',
        entityId: 'condition-1',
      );

      expect(differentUser, isFalse);
      expect(differentEntity, isFalse);
      expect(differentType, isFalse);
    },
  );

  test(
    'hasPendingOperation should return false for non-pending entries',
    () async {
      await outboxDao.insertOutbox(createEntry(status: 'processing'));

      final result = await outboxDao.hasPendingOperation(
        userId: 'user-1',
        entityType: 'condition',
        entityId: 'condition-1',
      );

      expect(result, isFalse);
    },
  );

  test('resolveKeepLocal should rebase conflicted entry and preserve local changes', () async {
    final originalCreatedAt = DateTime(2026, 11, 18, 9);

    await outboxDao.insertOutbox(
      createEntry(
        id: 'keep-local-1',
        payload: '{"name":"Local Diabetes"}',
        operation: 'update',
        status: 'conflict',
        attempts: 2,
        lastError: 'Server version conflict',
        createdAt: originalCreatedAt,
        baseVersion: 1,
        conflictPayload: '{"currentVersion":3}',
      ),
    );

    final updatedCount = await outboxDao.resolveKeepLocal(
      id: 'keep-local-1',
      currentVersion: 3,
    );

    final entry = await outboxDao.getById('keep-local-1');

    expect(updatedCount, 1);
    expect(entry, isNotNull);

    expect(entry!.status, 'pending');
    expect(entry.baseVersion, 3);
    expect(entry.conflictPayload, isNull);
    expect(entry.lastError, isNull);

    // Local changes must remain untouched.
    expect(entry.payload, '{"name":"Local Diabetes"}');
    expect(entry.operation, 'update');
    expect(entry.attempts, 2);
    expect(entry.createdAt, originalCreatedAt);
  });

  test('resolveKeepLocal should not modify a non-conflicted entry', () async {
    await outboxDao.insertOutbox(
      createEntry(
        id: 'keep-local-pending-1',
        status: 'pending',
        baseVersion: 1,
      ),
    );

    final updatedCount = await outboxDao.resolveKeepLocal(
      id: 'keep-local-pending-1',
      currentVersion: 3,
    );

    final entry = await outboxDao.getById('keep-local-pending-1');

    expect(updatedCount, 0);
    expect(entry, isNotNull);
    expect(entry!.status, 'pending');
    expect(entry.baseVersion, 1);
  });

  test('getConflictEntries should return only conflicted entries for the requested user in order', () async {
    await outboxDao.insertOutbox(
      createEntry(
        id: 'conflict-later',
        userId: 'user-1',
        operation: 'update',
        status: 'conflict',
        createdAt: DateTime(2026, 10, 21, 12),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'pending',
        userId: 'user-1',
        status: 'pending',
        createdAt: DateTime(2026, 10, 21, 7),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'conflict-earlier',
        userId: 'user-1',
        operation: 'update',
        status: 'conflict',
        createdAt: DateTime(2026, 10, 21, 8),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'other-user-conflict',
        userId: 'user-2',
        operation: 'update',
        status: 'conflict',
        createdAt: DateTime(2026, 10, 21, 6),
      ),
    );

    await outboxDao.insertOutbox(
      createEntry(
        id: 'legacy-null-user-conflict',
        userId: null,
        operation: 'update',
        status: 'conflict',
        createdAt: DateTime(2026, 10, 21, 5),
      ),
    );

    final entries = await outboxDao.getConflictEntries(userId: 'user-1');

    expect(entries.map((entry) => entry.id).toList(), [
      'conflict-earlier',
      'conflict-later',
    ]);

    expect(entries.every((entry) => entry.status == 'conflict'), isTrue);
  });

  test(
    'getConflictEntries should return an empty list when no conflicts exist',
    () async {
      await outboxDao.insertOutbox(
        createEntry(id: 'pending-only', status: 'pending'),
      );

      final entries = await outboxDao.getConflictEntries(userId: 'user-1');

      expect(entries, isEmpty);
    },
  );
}
