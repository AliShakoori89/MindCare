import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Repositories/conflict_repository_impl.dart';

void main() {
  late AppDatabase database;
  late ConflictRepositoryImpl repository;

  const userId = 'user-1';
  const conditionId = 'condition-1';
  const medicationId = 'medication-1';

  final now = DateTime(2026, 11, 18, 10);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ConflictRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> createUser() async {
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(id: userId, createdAt: now, updatedAt: now),
        );
  }

  Future<void> insertConflict({
    String id = 'outbox-1',
    String entityType = 'condition',
    String entityId = conditionId,
    String operation = 'update',
    String? entryUserId = userId,
    String? conflictPayload,
    String payload = '{"name":"Local value"}',
    int? baseVersion = 1,
    String status = 'conflict',
    DateTime? createdAt,
  }) async {
    await database
        .into(database.outbox)
        .insert(
          OutboxCompanion.insert(
            id: id,
            userId: drift.Value(entryUserId),
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            status: status,
            attempts: const drift.Value(2),
            lastError: const drift.Value('Version conflict'),
            createdAt: createdAt ?? now,
            baseVersion: drift.Value(baseVersion),
            conflictPayload: drift.Value(conflictPayload),
          ),
        );
  }

  Map<String, dynamic> conditionSnapshot({
    String id = conditionId,
    String snapshotUserId = userId,
    String name = 'Server Diabetes',
    int version = 3,
  }) {
    return {
      'id': id,
      'userId': snapshotUserId,
      'name': name,
      'status': 'active',
      'diagnosedAt': null,
      'diagnosedBy': null,
      'notes': 'Updated on server',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.add(const Duration(hours: 1)).toIso8601String(),
      'deletedAt': null,
      'version': version,
    };
  }

  Map<String, dynamic> medicationSnapshot({
    String id = medicationId,
    String snapshotUserId = userId,
    String name = 'Server Aspirin',
    int version = 4,
  }) {
    return {
      'id': id,
      'userId': snapshotUserId,
      'name': name,
      'genericName': 'Acetylsalicylic Acid',
      'dosage': '100',
      'unit': 'mg',
      'frequencyType': 'daily',
      'frequencyValue': '1',
      'route': 'oral',
      'startDate': now.toIso8601String(),
      'endDate': null,
      'status': 'active',
      'prescribedBy': 'Dr. Server',
      'notes': 'Updated on server',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.add(const Duration(hours: 1)).toIso8601String(),
      'deletedAt': null,
      'version': version,
    };
  }

  Future<void> insertLocalCondition({String name = 'Local Diabetes'}) async {
    await database
        .into(database.conditions)
        .insert(
          ConditionsCompanion.insert(
            id: conditionId,
            userId: userId,
            name: name,
            status: 'active',
            createdAt: now,
            updatedAt: now,
            version: const drift.Value(1),
          ),
        );
  }

  Future<void> insertLocalMedication({String name = 'Local Aspirin'}) async {
    await database
        .into(database.medications)
        .insert(
          MedicationsCompanion.insert(
            id: medicationId,
            userId: userId,
            name: name,
            genericName: const drift.Value('Acetylsalicylic Acid'),
            dosage: const drift.Value('100'),
            unit: const drift.Value('mg'),
            frequencyType: 'daily',
            frequencyValue: const drift.Value('1'),
            route: 'oral',
            startDate: drift.Value(now),
            status: 'active',
            prescribedBy: const drift.Value('Dr. Local'),
            notes: const drift.Value('Local notes'),
            createdAt: now,
            updatedAt: now,
            version: const drift.Value(1),
          ),
        );
  }

  test(
    'getConflicts should return only conflicts for requested user in order',
    () async {
      await createUser();

      const conflictPayload = '{"currentVersion":3}';

      await insertConflict(
        id: 'conflict-later',
        createdAt: DateTime(2026, 11, 18, 12),
        conflictPayload: conflictPayload,
        payload: '{"name":"Local later"}',
        baseVersion: 2,
      );

      await insertConflict(
        id: 'pending-entry',
        status: 'pending',
        createdAt: DateTime(2026, 11, 18, 7),
        conflictPayload: null,
      );

      await insertConflict(
        id: 'conflict-earlier',
        createdAt: DateTime(2026, 11, 18, 8),
        conflictPayload: conflictPayload,
        payload: '{"name":"Local earlier"}',
        baseVersion: 1,
      );

      await insertConflict(
        id: 'other-user-conflict',
        entryUserId: 'another-user',
        conflictPayload: conflictPayload,
        createdAt: DateTime(2026, 11, 18, 6),
      );

      await insertConflict(
        id: 'legacy-null-user-conflict',
        entryUserId: null,
        conflictPayload: conflictPayload,
        createdAt: DateTime(2026, 11, 18, 5),
      );

      final conflicts = await repository.getConflicts(userId: userId);

      expect(conflicts, hasLength(2));

      expect(conflicts.map((entry) => entry.outboxId).toList(), [
        'conflict-earlier',
        'conflict-later',
      ]);

      final firstConflict = conflicts.first;

      expect(firstConflict.entityType, 'condition');
      expect(firstConflict.entityId, conditionId);
      expect(firstConflict.operation, 'update');
      expect(firstConflict.payload, '{"name":"Local earlier"}');
      expect(firstConflict.baseVersion, 1);
      expect(firstConflict.conflictPayload, conflictPayload);
      expect(firstConflict.createdAt, DateTime(2026, 11, 18, 8));
      expect(firstConflict.lastError, 'Version conflict');
    },
  );

  test(
    'getConflicts should return empty list when no conflicts exist',
    () async {
      await createUser();

      await insertConflict(
        id: 'pending-entry',
        status: 'pending',
        conflictPayload: null,
      );

      final conflicts = await repository.getConflicts(userId: userId);

      expect(conflicts, isEmpty);
    },
  );

  test('keepLocal should rebase conflict and preserve local changes', () async {
    await createUser();

    await insertConflict(
      conflictPayload: jsonEncode({
        'currentVersion': 3,
        'currentData': conditionSnapshot(),
      }),
    );

    await repository.keepLocal(outboxId: 'outbox-1', userId: userId);

    final entry = await database.outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.status, 'pending');
    expect(entry.baseVersion, 3);
    expect(entry.conflictPayload, isNull);
    expect(entry.lastError, isNull);
    expect(entry.payload, '{"name":"Local value"}');
    expect(entry.operation, 'update');
    expect(entry.attempts, 2);
  });

  test(
    'acceptServer should apply condition snapshot and delete outbox',
    () async {
      await createUser();
      await insertLocalCondition();

      await insertConflict(
        conflictPayload: jsonEncode({
          'currentVersion': 3,
          'currentData': conditionSnapshot(),
        }),
      );

      await repository.acceptServer(outboxId: 'outbox-1', userId: userId);

      final condition = await database.conditionsDao.getConditionById(
        conditionId,
      );
      final entry = await database.outboxDao.getById('outbox-1');

      expect(condition, isNotNull);
      expect(condition!.name, 'Server Diabetes');
      expect(condition.notes, 'Updated on server');
      expect(condition.version, 3);
      expect(entry, isNull);
    },
  );

  test(
    'acceptServer should apply medication snapshot and delete outbox',
    () async {
      await createUser();
      await insertLocalMedication();

      await insertConflict(
        entityType: 'medication',
        entityId: medicationId,
        conflictPayload: jsonEncode({
          'currentVersion': 4,
          'currentData': medicationSnapshot(),
        }),
      );

      await repository.acceptServer(outboxId: 'outbox-1', userId: userId);

      final medication = await database.medicationsDao.getMedicationById(
        medicationId,
      );
      final entry = await database.outboxDao.getById('outbox-1');

      expect(medication, isNotNull);
      expect(medication!.name, 'Server Aspirin');
      expect(medication.prescribedBy, 'Dr. Server');
      expect(medication.version, 4);
      expect(entry, isNull);
    },
  );

  test(
    'acceptServer should rollback when snapshot version is invalid',
    () async {
      await createUser();
      await insertLocalCondition();

      await insertConflict(
        conflictPayload: jsonEncode({
          'currentVersion': 3,
          'currentData': conditionSnapshot(version: 2),
        }),
      );

      await expectLater(
        repository.acceptServer(outboxId: 'outbox-1', userId: userId),
        throwsA(isA<FormatException>()),
      );

      final condition = await database.conditionsDao.getConditionById(
        conditionId,
      );
      final entry = await database.outboxDao.getById('outbox-1');

      expect(condition, isNotNull);
      expect(condition!.name, 'Local Diabetes');
      expect(condition.version, 1);
      expect(entry, isNotNull);
      expect(entry!.status, 'conflict');
    },
  );

  test(
    'acceptServer should reject snapshot belonging to another user',
    () async {
      await createUser();
      await insertLocalCondition();

      await insertConflict(
        conflictPayload: jsonEncode({
          'currentVersion': 3,
          'currentData': conditionSnapshot(snapshotUserId: 'another-user'),
        }),
      );

      await expectLater(
        repository.acceptServer(outboxId: 'outbox-1', userId: userId),
        throwsA(isA<FormatException>()),
      );

      final condition = await database.conditionsDao.getConditionById(
        conditionId,
      );
      final entry = await database.outboxDao.getById('outbox-1');

      expect(condition, isNotNull);
      expect(condition!.name, 'Local Diabetes');
      expect(entry, isNotNull);
      expect(entry!.status, 'conflict');
    },
  );

  test('keepLocal should reject an entry belonging to another user', () async {
    await createUser();

    await insertConflict(
      entryUserId: 'another-user',
      conflictPayload: jsonEncode({
        'currentVersion': 3,
        'currentData': conditionSnapshot(),
      }),
    );

    await expectLater(
      repository.keepLocal(outboxId: 'outbox-1', userId: userId),
      throwsA(isA<StateError>()),
    );

    final entry = await database.outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.status, 'conflict');
    expect(entry.baseVersion, 1);
  });

  test(
    'acceptServer should reject missing currentData without changes',
    () async {
      await createUser();
      await insertLocalCondition();

      await insertConflict(conflictPayload: jsonEncode({'currentVersion': 3}));

      await expectLater(
        repository.acceptServer(outboxId: 'outbox-1', userId: userId),
        throwsA(isA<FormatException>()),
      );

      final condition = await database.conditionsDao.getConditionById(
        conditionId,
      );
      final entry = await database.outboxDao.getById('outbox-1');

      expect(condition, isNotNull);
      expect(condition!.name, 'Local Diabetes');
      expect(entry, isNotNull);
      expect(entry!.status, 'conflict');
    },
  );

  test('repository should reject non-update conflicts', () async {
    await createUser();

    await insertConflict(
      operation: 'delete',
      conflictPayload: jsonEncode({
        'currentVersion': 3,
        'currentData': conditionSnapshot(),
      }),
    );

    await expectLater(
      repository.keepLocal(outboxId: 'outbox-1', userId: userId),
      throwsA(isA<UnsupportedError>()),
    );

    final entry = await database.outboxDao.getById('outbox-1');

    expect(entry, isNotNull);
    expect(entry!.status, 'conflict');
  });
}
