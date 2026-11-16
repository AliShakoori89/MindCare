import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_change_model.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_response_model.dart';
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_local_data_source_impl.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Core/Sync/Domain/Services/sync_manager.dart';

import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';

import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source_impl.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_remote_data_source.dart';
import 'package:mind_care/Features/Conditions/Data/Repositories/condition_repository_impl.dart';
import 'package:mind_care/Features/Conditions/Data/Models/condition_model.dart';
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';

import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_remote_data_source.dart';

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

class MockConditionRemoteDataSource extends Mock
    implements ConditionRemoteDataSource {}

class MockMedicationRemoteDataSource extends Mock
    implements MedicationRemoteDataSource {}

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

void main() {
  late db.AppDatabase database;
  late ConditionRepositoryImpl conditionRepository;
  late MockConditionRemoteDataSource conditionRemoteDataSource;
  late MockSyncRemoteDataSource syncRemoteDataSource;
  late MockMedicationRemoteDataSource medicationRemoteDataSource;
  late MockGetCurrentSession getCurrentSession;
  late SyncManager syncManager;
  late MedicationLocalDataSourceImpl medicationLocalDataSource;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'test-token',
  );

  final timestamp = DateTime.utc(2026, 11, 1, 10);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());

    conditionRemoteDataSource = MockConditionRemoteDataSource();
    syncRemoteDataSource = MockSyncRemoteDataSource();
    medicationRemoteDataSource = MockMedicationRemoteDataSource();
    getCurrentSession = MockGetCurrentSession();
    medicationLocalDataSource = MedicationLocalDataSourceImpl(database);

    final localDataSource = ConditionLocalDataSourceImpl(database);

    conditionRepository = ConditionRepositoryImpl(localDataSource);

    syncManager = SyncManager(
      db: database,
      remoteDataSource: syncRemoteDataSource,
      getCurrentSession: getCurrentSession,
      conditionRemoteDataSource: conditionRemoteDataSource,
      medicationRemoteDataSource: medicationRemoteDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('stores condition offline and pushes it after reconnection', () async {
    // Arrange: create the authenticated user's local record.
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final condition = Condition(
      id: 'condition-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      diagnosedAt: DateTime.utc(2025, 5, 10),
      diagnosedBy: 'Dr. Test',
      notes: 'Integration test',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    // Act 1: create condition while offline.
    // No sync is triggered here.
    await conditionRepository.createCondition(condition);

    // Assert 1: condition is stored locally.
    final localCondition = await database.conditionsDao.getConditionById(
      'condition-1',
    );

    expect(localCondition, isNotNull);
    expect(localCondition!.id, condition.id);
    expect(localCondition.userId, session.userId);
    expect(localCondition.name, 'Asthma');
    expect(localCondition.status, 'active');

    // Assert 2: an Outbox entry is created.
    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, hasLength(1));

    final outboxEntry = pendingEntries.single;

    expect(outboxEntry.entityType, 'condition');
    expect(outboxEntry.entityId, condition.id);
    expect(outboxEntry.operation, 'create');
    expect(outboxEntry.status, 'pending');
    expect(outboxEntry.attempts, 0);

    // The remote server must not be called while offline.
    verifyNever(
      () => conditionRemoteDataSource.createCondition(
        id: any(named: 'id'),
        name: any(named: 'name'),
        status: any(named: 'status'),
        diagnosedAt: any(named: 'diagnosedAt'),
        diagnosedBy: any(named: 'diagnosedBy'),
        notes: any(named: 'notes'),
      ),
    );

    // Arrange: simulate an authenticated session after reconnection.
    when(() => getCurrentSession()).thenAnswer((_) async => session);

    when(
      () => conditionRemoteDataSource.createCondition(
        id: condition.id,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
      ),
    ).thenAnswer(
      (_) async => ConditionModel(
        id: condition.id,
        userId: session.userId,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    // Act 2: internet is available again; run synchronization.
    await syncManager.pushChanges();

    // Assert 3: the remote data source received the correct data.
    verify(
      () => conditionRemoteDataSource.createCondition(
        id: condition.id,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
      ),
    ).called(1);

    // Assert 4: successful synchronization removes the Outbox entry.
    final remainingEntry = await database.outboxDao.getById(outboxEntry.id);

    expect(remainingEntry, isNull);

    final remainingPendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(remainingPendingEntries, isEmpty);

    // Assert 5: local data remains available after synchronization.
    final finalCondition = await database.conditionsDao.getConditionById(
      condition.id,
    );

    expect(finalCondition, isNotNull);
    expect(finalCondition!.name, condition.name);
    expect(finalCondition.userId, session.userId);
  });

  test('keeps failed outbox entry and retries it successfully', () async {
    // Arrange: create the authenticated user's local record.
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final condition = Condition(
      id: 'condition-retry-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      diagnosedAt: DateTime.utc(2025, 5, 10),
      diagnosedBy: 'Dr. Test',
      notes: 'Retry integration test',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await conditionRepository.createCondition(condition);

    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, hasLength(1));

    final outboxEntry = pendingEntries.single;

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    // First attempt: simulate network failure.
    when(
      () => conditionRemoteDataSource.createCondition(
        id: condition.id,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
      ),
    ).thenThrow(Exception('Network unavailable'));

    // Act 1: first synchronization attempt.
    await syncManager.pushChanges();

    // Assert 1: failed entry must remain pending.
    final failedEntry = await database.outboxDao.getById(outboxEntry.id);

    expect(failedEntry, isNotNull);
    expect(failedEntry!.status, 'pending');
    expect(failedEntry.attempts, 1);
    expect(failedEntry.lastError, isNotNull);
    expect(failedEntry.lastError, contains('Network unavailable'));

    // Second attempt: simulate successful remote response.
    when(
      () => conditionRemoteDataSource.createCondition(
        id: condition.id,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
      ),
    ).thenAnswer(
      (_) async => ConditionModel(
        id: condition.id,
        userId: session.userId,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    // Act 2: retry synchronization.
    await syncManager.pushChanges();

    // Assert 2: successful retry removes the Outbox entry.
    final removedEntry = await database.outboxDao.getById(outboxEntry.id);

    expect(removedEntry, isNull);

    final remainingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(remainingEntries, isEmpty);

    // Assert 3: local condition must still exist.
    final localCondition = await database.conditionsDao.getConditionById(
      condition.id,
    );

    expect(localCondition, isNotNull);
    expect(localCondition!.name, condition.name);
    expect(localCondition.userId, session.userId);

    // Assert 4: remote create was attempted twice.
    verify(
      () => conditionRemoteDataSource.createCondition(
        id: condition.id,
        name: condition.name,
        status: condition.status,
        diagnosedAt: condition.diagnosedAt,
        diagnosedBy: condition.diagnosedBy,
        notes: condition.notes,
      ),
    ).called(2);
  });

  test('updates condition offline and pushes it after reconnection', () async {
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final originalCondition = Condition(
      id: 'condition-update-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await conditionRepository.createCondition(originalCondition);

    // Remove the initial create entry to isolate the update operation.
    final createEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(createEntries, hasLength(1));

    await database.outboxDao.deleteById(createEntries.single.id);

    final updatedCondition = Condition(
      id: originalCondition.id,
      userId: session.userId,
      name: 'Chronic Asthma',
      status: 'under_treatment',
      diagnosedAt: DateTime.utc(2025, 5, 10),
      diagnosedBy: 'Dr. Test',
      notes: 'Updated offline',
      createdAt: timestamp,
      updatedAt: timestamp.add(const Duration(minutes: 5)),
    );

    // Act: update while offline.
    await conditionRepository.updateCondition(updatedCondition);

    // Assert: local data is updated.
    final localCondition = await database.conditionsDao.getConditionById(
      originalCondition.id,
    );

    expect(localCondition, isNotNull);
    expect(localCondition!.name, 'Chronic Asthma');
    expect(localCondition.status, 'under_treatment');

    // Assert: update operation is stored in Outbox.
    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, hasLength(1));
    expect(pendingEntries.single.operation, 'update');
    expect(pendingEntries.single.entityId, originalCondition.id);

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    when(
      () => conditionRemoteDataSource.updateCondition(
        id: updatedCondition.id,
        name: updatedCondition.name,
        status: updatedCondition.status,
        diagnosedAt: updatedCondition.diagnosedAt,
        diagnosedBy: updatedCondition.diagnosedBy,
        notes: updatedCondition.notes,
        expectedVersion: 1,
      ),
    ).thenAnswer(
      (_) async => ConditionModel(
        id: updatedCondition.id,
        userId: session.userId,
        name: updatedCondition.name,
        status: updatedCondition.status,
        diagnosedAt: updatedCondition.diagnosedAt,
        diagnosedBy: updatedCondition.diagnosedBy,
        notes: updatedCondition.notes,
        createdAt: timestamp,
        updatedAt: updatedCondition.updatedAt,
      ),
    );

    // Act: synchronize after reconnection.
    await syncManager.pushChanges();

    // Assert: remote update is called.
    verify(
      () => conditionRemoteDataSource.updateCondition(
        id: updatedCondition.id,
        name: updatedCondition.name,
        status: updatedCondition.status,
        diagnosedAt: updatedCondition.diagnosedAt,
        diagnosedBy: updatedCondition.diagnosedBy,
        notes: updatedCondition.notes,
        expectedVersion: 1,
      ),
    ).called(1);

    // Assert: Outbox entry is removed.
    final remainingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(remainingEntries, isEmpty);

    // Local data remains available.
    final finalCondition = await database.conditionsDao.getConditionById(
      updatedCondition.id,
    );

    expect(finalCondition, isNotNull);
    expect(finalCondition!.name, updatedCondition.name);
  });

  test('deletes condition offline and pushes it after reconnection', () async {
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final condition = Condition(
      id: 'condition-delete-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await conditionRepository.createCondition(condition);

    // Remove initial create operation to isolate delete.
    final createEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(createEntries, hasLength(1));

    await database.outboxDao.deleteById(createEntries.single.id);

    // Act: delete while offline.
    await conditionRepository.deleteCondition(condition.id);

    // Assert: condition is no longer visible in normal queries.
    final visibleCondition = await database.conditionsDao.getConditionById(
      condition.id,
    );

    expect(visibleCondition, isNull);

    // Assert: record still exists with deletedAt.
    final deletedCondition = await database.conditionsDao
        .getConditionByIdIncludingDeleted(condition.id);

    expect(deletedCondition, isNotNull);
    expect(deletedCondition!.deletedAt, isNotNull);

    // Assert: delete operation is stored in Outbox.
    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, hasLength(1));
    expect(pendingEntries.single.operation, 'delete');
    expect(pendingEntries.single.entityId, condition.id);

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    when(() => conditionRemoteDataSource.deleteCondition(condition.id))
        .thenAnswer((_) async {});

    // Act: synchronize after reconnection.
    await syncManager.pushChanges();

    // Assert: remote delete is called.
    verify(() => conditionRemoteDataSource.deleteCondition(condition.id))
        .called(1);

    // Assert: Outbox entry is removed.
    final remainingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(remainingEntries, isEmpty);

    // Soft-deleted record remains in local database.
    final finalCondition = await database.conditionsDao
        .getConditionByIdIncludingDeleted(condition.id);

    expect(finalCondition, isNotNull);
    expect(finalCondition!.deletedAt, isNotNull);
  });

  test('pushes create and multiple updates in the correct order', () async {
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final originalCondition = Condition(
      id: 'condition-order-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    // Create
    await conditionRepository.createCondition(originalCondition);

    // Update 1
    final firstUpdate = Condition(
      id: originalCondition.id,
      userId: session.userId,
      name: 'Chronic Asthma',
      status: 'active',
      createdAt: timestamp,
      updatedAt: timestamp.add(const Duration(minutes: 1)),
    );

    await conditionRepository.updateCondition(firstUpdate);

    // Update 2
    final secondUpdate = Condition(
      id: originalCondition.id,
      userId: session.userId,
      name: 'Severe Asthma',
      status: 'under_treatment',
      createdAt: timestamp,
      updatedAt: timestamp.add(const Duration(minutes: 2)),
    );

    await conditionRepository.updateCondition(secondUpdate);

    // Verify Outbox order.
    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, hasLength(1));
    expect(pendingEntries.single.operation, 'create');

    expect(pendingEntries.single.payload, contains('"name":"Severe Asthma"'));

    expect(
      pendingEntries.single.payload,
      contains('"status":"under_treatment"'),
    );

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    final remoteOperations = <String>[];

    when(
      () => conditionRemoteDataSource.createCondition(
        id: secondUpdate.id,
        name: secondUpdate.name,
        status: secondUpdate.status,
        diagnosedAt: secondUpdate.diagnosedAt,
        diagnosedBy: secondUpdate.diagnosedBy,
        notes: secondUpdate.notes,
      ),
    ).thenAnswer((_) async {
      remoteOperations.add('create');

      return ConditionModel(
        id: secondUpdate.id,
        userId: session.userId,
        name: secondUpdate.name,
        status: secondUpdate.status,
        diagnosedAt: secondUpdate.diagnosedAt,
        diagnosedBy: secondUpdate.diagnosedBy,
        notes: secondUpdate.notes,
        createdAt: secondUpdate.createdAt,
        updatedAt: secondUpdate.updatedAt,
      );
    });

    // Synchronize.
    await syncManager.pushChanges();

    // Verify exact operation order.
    expect(remoteOperations, ['create']);
    // Verify Outbox is empty.
    final remainingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(remainingEntries, isEmpty);

    // Verify final local data.
    final finalCondition = await database.conditionsDao.getConditionById(
      originalCondition.id,
    );

    expect(finalCondition, isNotNull);
    expect(finalCondition!.name, 'Severe Asthma');
    expect(finalCondition.status, 'under_treatment');
    expect(pendingEntries, hasLength(1));

    expect(pendingEntries.single.operation, 'create');

    expect(pendingEntries.single.payload, contains('"name":"Severe Asthma"'));

    expect(
      pendingEntries.single.payload,
      contains('"status":"under_treatment"'),
    );
  });

  test('blocks subsequent operations for an entity when a previous operation fails', () async {
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final condition = Condition(
      id: 'condition-failure-order-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      diagnosedAt: null,
      diagnosedBy: null,
      notes: null,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    // Seed a condition that already exists on the server.
    // This must not create an Outbox entry.
    await database.conditionsDao.applyRemoteCondition(
      db.ConditionsCompanion.insert(
        id: condition.id,
        userId: condition.userId,
        name: condition.name,
        status: condition.status,
        createdAt: condition.createdAt,
        updatedAt: condition.updatedAt,
      ),
    );

    // Register two separate operations: update, then delete.
    await conditionRepository.updateCondition(
      condition.copyWith(name: 'Chronic Asthma'),
    );

    await Future.delayed(const Duration(milliseconds: 2));

    await conditionRepository.deleteCondition(condition.id);

    final outboxBeforeSync = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(outboxBeforeSync.map((entry) => entry.operation).toList(), [
      'update',
      'delete',
    ]);

    expect(outboxBeforeSync.first.baseVersion, 1);

    final remoteOperations = <String>[];

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    // First update fails.
    when(
      () => conditionRemoteDataSource.updateCondition(
        id: condition.id,
        name: 'Chronic Asthma',
        status: 'active',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: null,
        expectedVersion: 1,
      ),
    ).thenAnswer((_) async {
      remoteOperations.add('update-failed');
      throw Exception('Update failed');
    });

    // This must not execute during the first sync.
    when(() => conditionRemoteDataSource.deleteCondition(condition.id))
        .thenAnswer((_) async {
          remoteOperations.add('delete');
        });

    // First sync: update fails, so delete must be blocked.
    await syncManager.pushChanges();

    expect(remoteOperations, ['update-failed']);

    var outboxAfterFirstSync = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(outboxAfterFirstSync.map((entry) => entry.operation).toList(), [
      'update',
      'delete',
    ]);

    expect(outboxAfterFirstSync[0].attempts, 1);
    expect(outboxAfterFirstSync[0].lastError, contains('Update failed'));
    expect(outboxAfterFirstSync[1].attempts, 0);

    // Retry: update now succeeds.
    when(
      () => conditionRemoteDataSource.updateCondition(
        id: condition.id,
        name: 'Chronic Asthma',
        status: 'active',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: null,
        expectedVersion: 1,
      ),
    ).thenAnswer((_) async {
      remoteOperations.add('update-retry');

      return ConditionModel(
        id: condition.id,
        userId: session.userId,
        name: 'Chronic Asthma',
        status: 'active',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: null,
        createdAt: timestamp,
        updatedAt: timestamp,
        version: 2,
      );
    });

    // Second sync: update succeeds, then delete is allowed.
    await syncManager.pushChanges();

    expect(remoteOperations, ['update-failed', 'update-retry', 'delete']);

    final outboxAfterSecondSync = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(outboxAfterSecondSync, isEmpty);

    final localCondition = await database.conditionsDao.getConditionById(
      condition.id,
    );

    expect(localCondition, isNull);
  });

  test('pulls remote condition and stores it locally without creating outbox entry', () async {
    // Arrange
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    final conditionJson = <String, dynamic>{
      'id': 'condition-remote-1',
      'userId': session.userId,
      'name': 'Diabetes',
      'status': 'active',
      'diagnosedAt': null,
      'diagnosedBy': null,
      'notes': 'Received from server',
      'createdAt': timestamp.toIso8601String(),
      'updatedAt': timestamp.toIso8601String(),
      'deletedAt': null,
    };

    final newCursor = timestamp.add(const Duration(minutes: 5));

    when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
      (_) async => SyncResponseModel(
        cursor: newCursor.toIso8601String(),
        changes: [
          SyncChangeModel(
            entity: 'condition',
            operation: 'created',
            id: 'condition-remote-1',
            data: conditionJson,
            timestamp: timestamp,
          ),
        ],
      ),
    );

    // Act
    await syncManager.pullChanges();

    // Assert
    final localCondition = await database.conditionsDao.getConditionById(
      'condition-remote-1',
    );

    expect(localCondition, isNotNull);
    expect(localCondition!.id, 'condition-remote-1');
    expect(localCondition.userId, session.userId);
    expect(localCondition.name, 'Diabetes');

    final savedCursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(savedCursor, isNotNull);
    expect(savedCursor!.cursor, newCursor.toIso8601String());

    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, isEmpty);
  });

  test('uses previously saved cursor when pulling changes again', () async {
    // Arrange
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    final previousCursor = timestamp.subtract(const Duration(minutes: 10));

    await database.syncCursorDao.upsertCursor(
      db.SyncCursorsCompanion.insert(
        id: 'cursor-1',
        userId: session.userId,
        cursor: Value(previousCursor.toIso8601String()),
        updatedAt: timestamp,
      ),
    );

    when(
      () => syncRemoteDataSource.getChanges(
        cursor: previousCursor.toIso8601String(),
      ),
    ).thenAnswer(
      (_) async =>
          SyncResponseModel(cursor: timestamp.toIso8601String(), changes: []),
    );

    // Act
    await syncManager.pullChanges();

    // Assert
    verify(
      () => syncRemoteDataSource.getChanges(
        cursor: previousCursor.toIso8601String(),
      ),
    ).called(1);

    final savedCursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(savedCursor, isNotNull);
    expect(savedCursor!.cursor, timestamp.toIso8601String());
  });

  test(
    'updates existing condition when the same remote change is pulled again',
    () async {
      // Arrange
      await database.usersDao.insertUser(
        db.UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      when(() => getCurrentSession()).thenAnswer((_) async => session);

      final conditionId = 'condition-duplicate-1';

      final firstConditionJson = <String, dynamic>{
        'id': conditionId,
        'userId': session.userId,
        'name': 'Diabetes',
        'status': 'active',
        'diagnosedAt': null,
        'diagnosedBy': null,
        'notes': 'First version',
        'createdAt': timestamp.toIso8601String(),
        'updatedAt': timestamp.toIso8601String(),
        'deletedAt': null,
      };

      final updatedConditionJson = <String, dynamic>{
        ...firstConditionJson,
        'name': 'Updated Diabetes',
        'notes': 'Updated version',
        'updatedAt': timestamp
            .add(const Duration(minutes: 5))
            .toIso8601String(),
      };

      final firstCursor = timestamp.toIso8601String();
      final secondCursor = timestamp
          .add(const Duration(minutes: 10))
          .toIso8601String();

      // First Pull
      when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
        (_) async => SyncResponseModel(
          cursor: firstCursor,
          changes: [
            SyncChangeModel(
              entity: 'condition',
              operation: 'created',
              id: conditionId,
              data: firstConditionJson,
              timestamp: timestamp,
            ),
          ],
        ),
      );

      await syncManager.pullChanges();

      // Second Pull: same ID, updated data
      when(() => syncRemoteDataSource.getChanges(cursor: firstCursor))
          .thenAnswer(
            (_) async => SyncResponseModel(
              cursor: secondCursor,
              changes: [
                SyncChangeModel(
                  entity: 'condition',
                  operation: 'updated',
                  id: conditionId,
                  data: updatedConditionJson,
                  timestamp: timestamp.add(const Duration(minutes: 5)),
                ),
              ],
            ),
          );

      // Act
      await syncManager.pullChanges();

      // Assert
      final conditions = await database.conditionsDao.getConditionsByUserId(
        session.userId,
      );

      expect(conditions.length, 1);
      expect(conditions.single.id, conditionId);
      expect(conditions.single.name, 'Updated Diabetes');
      expect(conditions.single.notes, 'Updated version');

      final savedCursor = await database.syncCursorDao.getByUserId(
        session.userId,
      );

      expect(savedCursor!.cursor, secondCursor);

      final pendingEntries = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(pendingEntries, isEmpty);
    },
  );

  test('soft deletes condition when remote delete change is pulled', () async {
    // Arrange
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    const conditionId = 'condition-remote-delete-1';

    final conditionJson = <String, dynamic>{
      'id': conditionId,
      'userId': session.userId,
      'name': 'Diabetes',
      'status': 'active',
      'diagnosedAt': null,
      'diagnosedBy': null,
      'notes': 'Remote delete test',
      'createdAt': timestamp.toIso8601String(),
      'updatedAt': timestamp.toIso8601String(),
      'deletedAt': null,
    };

    final firstCursor = timestamp.toIso8601String();
    final secondCursor = timestamp
        .add(const Duration(minutes: 5))
        .toIso8601String();

    // First Pull: create condition
    when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
      (_) async => SyncResponseModel(
        cursor: firstCursor,
        changes: [
          SyncChangeModel(
            entity: 'condition',
            operation: 'created',
            id: conditionId,
            data: conditionJson,
            timestamp: timestamp,
          ),
        ],
      ),
    );

    await syncManager.pullChanges();

    // Second Pull: delete condition
    final deletedAt = timestamp.add(const Duration(minutes: 5));

    when(() => syncRemoteDataSource.getChanges(cursor: firstCursor)).thenAnswer(
      (_) async => SyncResponseModel(
        cursor: secondCursor,
        changes: [
          SyncChangeModel(
            entity: 'condition',
            operation: 'deleted',
            id: conditionId,
            data: null,
            timestamp: deletedAt,
          ),
        ],
      ),
    );

    // Act
    await syncManager.pullChanges();

    // Assert: record should not appear in normal queries
    final visibleCondition = await database.conditionsDao.getConditionById(
      conditionId,
    );

    expect(visibleCondition, isNull);

    // Assert: record should still exist as soft-deleted
    final deletedCondition = await database.conditionsDao
        .getConditionByIdIncludingDeleted(conditionId);

    expect(deletedCondition, isNotNull);
    expect(deletedCondition!.deletedAt?.toUtc(), deletedAt.toUtc());

    expect(deletedCondition.updatedAt.toUtc(), deletedAt.toUtc());

    // Assert: cursor should be updated
    final savedCursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(savedCursor!.cursor, secondCursor);

    // Assert: remote delete should not create an outbox entry
    final pendingEntries = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(pendingEntries, isEmpty);
  });

  test('preserves pending local changes when pulling remote changes', () async {
    // Arrange
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final condition = Condition(
      id: 'condition-local-pending-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      diagnosedAt: null,
      diagnosedBy: null,
      notes: 'Created offline',
      createdAt: timestamp,
      updatedAt: timestamp,
      deletedAt: null,
    );

    // Create condition locally while offline.
    await conditionRepository.createCondition(condition);

    final outboxBeforePull = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(outboxBeforePull, hasLength(1));

    final originalOutboxEntry = outboxBeforePull.single;

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
      (_) async =>
          SyncResponseModel(cursor: timestamp.toIso8601String(), changes: []),
    );

    // Act
    await syncManager.pullChanges();

    // Assert: local condition must remain.
    final localCondition = await database.conditionsDao.getConditionById(
      condition.id,
    );

    expect(localCondition, isNotNull);
    expect(localCondition!.name, condition.name);
    expect(localCondition.notes, condition.notes);

    // Assert: pending outbox entry must remain unchanged.
    final outboxAfterPull = await database.outboxDao.getPendingEntries(
      userId: session.userId,
    );

    expect(outboxAfterPull, hasLength(1));
    expect(outboxAfterPull.single.id, originalOutboxEntry.id);
    expect(outboxAfterPull.single.operation, originalOutboxEntry.operation);
    expect(outboxAfterPull.single.payload, originalOutboxEntry.payload);
    expect(outboxAfterPull.single.status, originalOutboxEntry.status);
    expect(outboxAfterPull.single.attempts, originalOutboxEntry.attempts);

    // Pull must not push local changes.
    verifyNever(
      () => conditionRemoteDataSource.createCondition(
        id: any(named: 'id'),
        name: any(named: 'name'),
        status: any(named: 'status'),
        diagnosedAt: any(named: 'diagnosedAt'),
        diagnosedBy: any(named: 'diagnosedBy'),
        notes: any(named: 'notes'),
      ),
    );
  });

  test('rolls back all pulled changes when one change is invalid', () async {
    // Arrange
    await database.usersDao.insertUser(
      db.UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    const previousCursor = '2026-10-31T10:00:00.000Z';
    const newCursor = '2026-11-01T10:00:00.000Z';

    await database.syncCursorDao.upsertCursor(
      db.SyncCursorsCompanion.insert(
        id: 'cursor-1',
        userId: session.userId,
        cursor: Value(previousCursor),
        updatedAt: timestamp,
      ),
    );

    final validCondition = ConditionModel(
      id: 'condition-rollback-1',
      userId: session.userId,
      name: 'Asthma',
      status: 'active',
      diagnosedAt: null,
      diagnosedBy: null,
      notes: 'Valid remote condition',
      createdAt: timestamp,
      updatedAt: timestamp,
      deletedAt: null,
    );

    when(() => getCurrentSession()).thenAnswer((_) async => session);

    when(() => syncRemoteDataSource.getChanges(cursor: previousCursor))
        .thenAnswer(
          (_) async => SyncResponseModel(
            cursor: newCursor,
            changes: [
              SyncChangeModel(
                entity: 'condition',
                operation: 'created',
                id: validCondition.id,
                data: validCondition.toJson(),
                timestamp: timestamp,
              ),
              SyncChangeModel(
                entity: 'condition',
                operation: 'created',
                id: 'condition-invalid-1',
                data: {
                  ...validCondition.toJson(),
                  'id': 'condition-invalid-1',
                  'userId': 'another-user',
                },
                timestamp: timestamp,
              ),
            ],
          ),
        );

    // Act & Assert
    await expectLater(
      syncManager.pullChanges(),
      throwsA(isA<FormatException>()),
    );

    // The first valid change must also be rolled back.
    final storedCondition = await database.conditionsDao.getConditionById(
      validCondition.id,
    );

    expect(storedCondition, isNull);

    // The previous cursor must remain unchanged.
    final storedCursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(storedCursor, isNotNull);
    expect(storedCursor!.cursor, previousCursor);
    expect(storedCursor.cursor, isNot(newCursor));
  });

  test(
    'preserves pending local condition when remote update arrives',
    () async {
      // Arrange
      await database.usersDao.insertUser(
        db.UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      final localCondition = Condition(
        id: 'condition-conflict-1',
        userId: session.userId,
        name: 'Local Updated Asthma',
        status: 'active',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: 'Local pending changes',
        createdAt: timestamp,
        updatedAt: timestamp,
        deletedAt: null,
      );

      // Create the local condition and its pending outbox entry.
      await conditionRepository.createCondition(localCondition);

      final outboxBeforePull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxBeforePull, hasLength(1));

      final originalOutboxEntry = outboxBeforePull.single;

      final remoteCondition = ConditionModel(
        id: localCondition.id,
        userId: session.userId,
        name: 'Remote Asthma',
        status: 'inactive',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: 'Remote changes',
        createdAt: timestamp,
        updatedAt: timestamp.add(const Duration(minutes: 1)),
        deletedAt: null,
      );

      when(() => getCurrentSession()).thenAnswer((_) async => session);

      when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
        (_) async => SyncResponseModel(
          cursor: timestamp.add(const Duration(minutes: 1)).toIso8601String(),
          changes: [
            SyncChangeModel(
              entity: 'condition',
              operation: 'updated',
              id: remoteCondition.id,
              data: remoteCondition.toJson(),
              timestamp: timestamp.add(const Duration(minutes: 1)),
            ),
          ],
        ),
      );

      // Act
      await syncManager.pullChanges();

      // Assert: local version must be preserved.
      final storedCondition = await database.conditionsDao.getConditionById(
        localCondition.id,
      );

      expect(storedCondition, isNotNull);
      expect(storedCondition!.name, localCondition.name);
      expect(storedCondition.status, localCondition.status);
      expect(storedCondition.notes, localCondition.notes);

      // Assert: pending outbox entry must remain unchanged.
      final outboxAfterPull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxAfterPull, hasLength(1));
      expect(outboxAfterPull.single.id, originalOutboxEntry.id);
      expect(outboxAfterPull.single.payload, originalOutboxEntry.payload);
      expect(outboxAfterPull.single.status, originalOutboxEntry.status);
    },
  );

  test(
    'preserves pending local condition when remote delete arrives',
    () async {
      // Arrange
      await database.usersDao.insertUser(
        db.UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      final condition = Condition(
        id: 'condition-conflict-delete-1',
        userId: session.userId,
        name: 'Local Asthma',
        status: 'active',
        diagnosedAt: null,
        diagnosedBy: null,
        notes: 'Local pending update',
        createdAt: timestamp,
        updatedAt: timestamp,
        deletedAt: null,
      );

      await conditionRepository.createCondition(condition);

      final outboxBeforePull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxBeforePull, hasLength(1));

      final originalOutboxEntry = outboxBeforePull.single;
      final remoteDeleteTime = timestamp.add(const Duration(minutes: 5));

      when(() => getCurrentSession()).thenAnswer((_) async => session);

      when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
        (_) async => SyncResponseModel(
          cursor: remoteDeleteTime.toIso8601String(),
          changes: [
            SyncChangeModel(
              entity: 'condition',
              operation: 'deleted',
              id: condition.id,
              data: null,
              timestamp: remoteDeleteTime,
            ),
          ],
        ),
      );

      // Act
      await syncManager.pullChanges();

      // Assert: local condition must remain active.
      final storedCondition = await database.conditionsDao.getConditionById(
        condition.id,
      );

      expect(storedCondition, isNotNull);
      expect(storedCondition!.name, condition.name);
      expect(storedCondition.deletedAt, isNull);

      // Assert: pending outbox entry must remain unchanged.
      final outboxAfterPull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxAfterPull, hasLength(1));
      expect(outboxAfterPull.single.id, originalOutboxEntry.id);
      expect(outboxAfterPull.single.payload, originalOutboxEntry.payload);

      // Assert: cursor must advance.
      final storedCursor = await database.syncCursorDao.getByUserId(
        session.userId,
      );

      expect(storedCursor, isNotNull);
      expect(storedCursor!.cursor, remoteDeleteTime.toIso8601String());
    },
  );

  test(
    'preserves pending local medication when remote update arrives',
    () async {
      // Arrange
      await database.usersDao.insertUser(
        db.UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      const medicationId = 'medication-conflict-1';

      // Create medication locally while offline.
      await medicationLocalDataSource.insertMedication(
        db.MedicationsCompanion.insert(
          id: medicationId,
          userId: session.userId,
          name: 'Local Medication',
          frequencyType: 'daily',
          route: 'oral',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
          dosage: const Value('10'),
          unit: const Value('mg'),
          notes: const Value('Local pending changes'),
        ),
      );

      final outboxBeforePull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxBeforePull, hasLength(1));

      final originalOutboxEntry = outboxBeforePull.single;

      expect(originalOutboxEntry.entityType, 'medication');
      expect(originalOutboxEntry.entityId, medicationId);
      expect(originalOutboxEntry.operation, 'create');
      expect(originalOutboxEntry.status, 'pending');

      final remoteUpdateTime = timestamp.add(const Duration(minutes: 5));

      final remoteMedicationJson = <String, dynamic>{
        'id': medicationId,
        'userId': session.userId,
        'name': 'Remote Medication',
        'genericName': 'Remote Generic',
        'dosage': '20',
        'unit': 'mg',
        'frequencyType': 'weekly',
        'frequencyValue': '2',
        'route': 'oral',
        'startDate': null,
        'endDate': null,
        'status': 'inactive',
        'prescribedBy': 'Remote Doctor',
        'notes': 'Remote changes',
        'createdAt': timestamp.toIso8601String(),
        'updatedAt': remoteUpdateTime.toIso8601String(),
        'deletedAt': null,
      };

      when(() => getCurrentSession()).thenAnswer((_) async => session);

      when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
        (_) async => SyncResponseModel(
          cursor: remoteUpdateTime.toIso8601String(),
          changes: [
            SyncChangeModel(
              entity: 'medication',
              operation: 'updated',
              id: medicationId,
              data: remoteMedicationJson,
              timestamp: remoteUpdateTime,
            ),
          ],
        ),
      );

      // Act
      await syncManager.pullChanges();

      // Assert: local medication must be preserved.
      final storedMedication = await database.medicationsDao.getMedicationById(
        medicationId,
      );

      expect(storedMedication, isNotNull);
      expect(storedMedication!.name, 'Local Medication');
      expect(storedMedication.dosage, '10');
      expect(storedMedication.unit, 'mg');
      expect(storedMedication.status, 'active');
      expect(storedMedication.notes, 'Local pending changes');
      expect(storedMedication.deletedAt, isNull);

      // Assert: pending Outbox entry must remain unchanged.
      final outboxAfterPull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxAfterPull, hasLength(1));
      expect(outboxAfterPull.single.id, originalOutboxEntry.id);
      expect(outboxAfterPull.single.entityType, originalOutboxEntry.entityType);
      expect(outboxAfterPull.single.entityId, originalOutboxEntry.entityId);
      expect(outboxAfterPull.single.operation, originalOutboxEntry.operation);
      expect(outboxAfterPull.single.payload, originalOutboxEntry.payload);
      expect(outboxAfterPull.single.status, originalOutboxEntry.status);
      expect(outboxAfterPull.single.attempts, originalOutboxEntry.attempts);

      // Assert: cursor must advance even though the remote update was skipped.
      final storedCursor = await database.syncCursorDao.getByUserId(
        session.userId,
      );

      expect(storedCursor, isNotNull);
      expect(storedCursor!.cursor, remoteUpdateTime.toIso8601String());
    },
  );

  test(
    'preserves pending local medication when remote delete arrives',
    () async {
      // Arrange
      await database.usersDao.insertUser(
        db.UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      const medicationId = 'medication-conflict-delete-1';

      // Create medication locally while offline.
      await medicationLocalDataSource.insertMedication(
        db.MedicationsCompanion.insert(
          id: medicationId,
          userId: session.userId,
          name: 'Local Medication',
          frequencyType: 'daily',
          route: 'oral',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
          dosage: const Value('15'),
          unit: const Value('mg'),
          notes: const Value('Local pending changes'),
        ),
      );

      final outboxBeforePull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxBeforePull, hasLength(1));

      final originalOutboxEntry = outboxBeforePull.single;
      final remoteDeleteTime = timestamp.add(const Duration(minutes: 5));

      when(() => getCurrentSession()).thenAnswer((_) async => session);

      when(() => syncRemoteDataSource.getChanges(cursor: null)).thenAnswer(
        (_) async => SyncResponseModel(
          cursor: remoteDeleteTime.toIso8601String(),
          changes: [
            SyncChangeModel(
              entity: 'medication',
              operation: 'deleted',
              id: medicationId,
              data: null,
              timestamp: remoteDeleteTime,
            ),
          ],
        ),
      );

      // Act
      await syncManager.pullChanges();

      // Assert: local medication must remain active.
      final storedMedication = await database.medicationsDao.getMedicationById(
        medicationId,
      );

      expect(storedMedication, isNotNull);
      expect(storedMedication!.name, 'Local Medication');
      expect(storedMedication.status, 'active');
      expect(storedMedication.notes, 'Local pending changes');
      expect(storedMedication.deletedAt, isNull);

      // Assert: pending Outbox entry must remain unchanged.
      final outboxAfterPull = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxAfterPull, hasLength(1));
      expect(outboxAfterPull.single.id, originalOutboxEntry.id);
      expect(outboxAfterPull.single.entityType, originalOutboxEntry.entityType);
      expect(outboxAfterPull.single.entityId, originalOutboxEntry.entityId);
      expect(outboxAfterPull.single.operation, originalOutboxEntry.operation);
      expect(outboxAfterPull.single.payload, originalOutboxEntry.payload);
      expect(outboxAfterPull.single.status, originalOutboxEntry.status);
      expect(outboxAfterPull.single.attempts, originalOutboxEntry.attempts);

      // Assert: cursor must advance even though the remote delete was skipped.
      final storedCursor = await database.syncCursorDao.getByUserId(
        session.userId,
      );

      expect(storedCursor, isNotNull);
      expect(storedCursor!.cursor, remoteDeleteTime.toIso8601String());
    },
  );
}
