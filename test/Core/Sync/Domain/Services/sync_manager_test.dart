import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_change_model.dart';
import 'package:mind_care/Features/Conditions/Data/Models/condition_model.dart';
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_remote_data_source.dart';
import 'package:mind_care/Features/Medications/Data/Models/medication_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_remote_data_source.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_response_model.dart';
import 'package:mind_care/Core/Sync/Domain/Services/sync_manager.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

class MockConditionRemoteDataSource extends Mock
    implements ConditionRemoteDataSource {}

class MockMedicationRemoteDataSource extends Mock
    implements MedicationRemoteDataSource {}

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

void main() {
  late AppDatabase database;
  late MockSyncRemoteDataSource remoteDataSource;
  late MockGetCurrentSession getCurrentSession;
  late SyncManager syncManager;
  late MockConditionRemoteDataSource conditionRemoteDataSource;
  late MockMedicationRemoteDataSource medicationRemoteDataSource;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'test-token',
  );

  const response = SyncResponseModel(
    cursor: '2026-10-24T06:00:00.000Z',
    changes: [],
  );

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    remoteDataSource = MockSyncRemoteDataSource();
    getCurrentSession = MockGetCurrentSession();
    conditionRemoteDataSource = MockConditionRemoteDataSource();
    medicationRemoteDataSource = MockMedicationRemoteDataSource();

    syncManager = SyncManager(
      db: database,
      remoteDataSource: remoteDataSource,
      conditionRemoteDataSource: conditionRemoteDataSource,
      getCurrentSession: getCurrentSession,
      medicationRemoteDataSource: medicationRemoteDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('does not request changes when there is no session', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => null);

    await expectLater(syncManager.pullChanges(), throwsA(isA<StateError>()));

    verifyNever(
      () => remoteDataSource.getChanges(cursor: any(named: 'cursor')),
    );
  });

  test('requests changes without cursor when no cursor is saved', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);
    when(() => remoteDataSource.getChanges(cursor: null))
        .thenAnswer((_) async => response);

    await syncManager.pullChanges();

    verify(() => remoteDataSource.getChanges(cursor: null)).called(1);
  });

  test('requests changes using the saved cursor', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);
    when(() => remoteDataSource.getChanges(cursor: '2026-10-24T05:00:00.000Z'))
        .thenAnswer((_) async => response);

    await database.syncCursorDao.insertCursor(
      SyncCursorsCompanion.insert(
        id: 'cursor-1',
        userId: session.userId,
        cursor: const drift.Value('2026-10-24T05:00:00.000Z'),
        updatedAt: DateTime(2026, 10, 24, 8),
      ),
    );

    await syncManager.pullChanges();

    verify(
      () => remoteDataSource.getChanges(cursor: '2026-10-24T05:00:00.000Z'),
    ).called(1);
  });

  test('applies a remote condition and saves the cursor', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);

    const newCursor = '2026-10-24T06:00:00.000Z';
    final timestamp = DateTime.utc(2026, 10, 24, 5, 30);

    final syncResponse = SyncResponseModel(
      cursor: newCursor,
      changes: [
        SyncChangeModel(
          entity: 'condition',
          operation: 'created',
          id: 'condition-1',
          timestamp: timestamp,
          data: {
            'id': 'condition-1',
            'userId': session.userId,
            'name': 'Asthma',
            'status': 'active',
            'diagnosedAt': null,
            'diagnosedBy': null,
            'notes': 'Remote sync test',
            'createdAt': timestamp.toIso8601String(),
            'updatedAt': timestamp.toIso8601String(),
            'deletedAt': null,
          },
        ),
      ],
    );

    when(() => remoteDataSource.getChanges(cursor: null))
        .thenAnswer((_) async => syncResponse);

    await database.usersDao.insertUser(
      UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    await syncManager.pullChanges();

    final savedCondition = await database.conditionsDao.getConditionById(
      'condition-1',
    );
    final savedCursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(savedCondition, isNotNull);
    expect(savedCondition!.name, 'Asthma');
    expect(savedCondition.userId, session.userId);
    expect(savedCursor?.cursor, newCursor);
  });

  test('applies a remote condition deletion and saves the cursor', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);

    final timestamp = DateTime.utc(2026, 10, 24, 5, 30);
    const newCursor = '2026-10-24T06:00:00.000Z';

    await database.usersDao.insertUser(
      UsersCompanion.insert(
        id: session.userId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    await database.conditionsDao.insertCondition(
      ConditionsCompanion.insert(
        id: 'condition-1',
        userId: session.userId,
        name: 'Asthma',
        status: 'active',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final syncResponse = SyncResponseModel(
      cursor: newCursor,
      changes: [
        SyncChangeModel(
          entity: 'condition',
          operation: 'deleted',
          id: 'condition-1',
          data: null,
          timestamp: timestamp.add(const Duration(minutes: 1)),
        ),
      ],
    );

    when(() => remoteDataSource.getChanges(cursor: null))
        .thenAnswer((_) async => syncResponse);

    await syncManager.pullChanges();

    final condition = await database.conditionsDao.getConditionById(
      'condition-1',
    );
    final cursor = await database.syncCursorDao.getByUserId(session.userId);

    expect(condition, isNull);
    expect(cursor?.cursor, newCursor);

    final rows = await database.select(database.conditions).get();
    expect(rows, hasLength(1));
    expect(rows.single.deletedAt, isNotNull);
  });

  test(
    'rolls back changes and does not advance cursor on unsupported entity',
    () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      final timestamp = DateTime.utc(2026, 10, 24, 5, 30);
      const initialCursor = '2026-10-24T05:00:00.000Z';

      await database.usersDao.insertUser(
        UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await database.syncCursorDao.insertCursor(
        SyncCursorsCompanion.insert(
          id: 'cursor-1',
          userId: session.userId,
          cursor: const drift.Value(initialCursor),
          updatedAt: timestamp,
        ),
      );

      final syncResponse = SyncResponseModel(
        cursor: '2026-10-24T06:00:00.000Z',
        changes: [
          SyncChangeModel(
            entity: 'condition',
            operation: 'created',
            id: 'condition-1',
            timestamp: timestamp,
            data: {
              'id': 'condition-1',
              'userId': session.userId,
              'name': 'Asthma',
              'status': 'active',
              'diagnosedAt': null,
              'diagnosedBy': null,
              'notes': null,
              'createdAt': timestamp.toIso8601String(),
              'updatedAt': timestamp.toIso8601String(),
              'deletedAt': null,
            },
          ),
          SyncChangeModel(
            entity: 'journal',
            operation: 'created',
            id: 'journal-1',
            data: null,
            timestamp: timestamp,
          ),
        ],
      );

      when(() => remoteDataSource.getChanges(cursor: initialCursor))
          .thenAnswer((_) async => syncResponse);

      await expectLater(
        syncManager.pullChanges(),
        throwsA(isA<UnsupportedError>()),
      );

      final condition = await database.conditionsDao.getConditionById(
        'condition-1',
      );
      final cursor = await database.syncCursorDao.getByUserId(session.userId);

      expect(condition, isNull);
      expect(cursor?.cursor, initialCursor);
    },
  );

  group('pushChanges', () {
    late DateTime timestamp;

    Future<void> seedUserAndCondition({
      String conditionId = 'condition-1',
      String userId = 'user-1',
      bool deleted = false,
    }) async {
      await database.usersDao.insertUser(
        UsersCompanion.insert(
          id: userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await database.conditionsDao.insertCondition(
        ConditionsCompanion.insert(
          id: conditionId,
          userId: userId,
          name: 'Asthma',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
          deletedAt: deleted
              ? drift.Value(timestamp)
              : const drift.Value.absent(),
        ),
      );
    }

    Future<void> addOutboxEntry({
      String id = 'outbox-1',
      String entityId = 'condition-1',
      String operation = 'create',
      String userId = 'user-1',
      String name = 'Asthma',
      String status = 'active',
      String payloadUserId = 'user-1',
    }) async {
      await database.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: id,
          userId: drift.Value(userId),
          entityType: 'condition',
          entityId: entityId,
          operation: operation,
          payload: jsonEncode({
            'userId': payloadUserId,
            'name': name,
            'status': status,
            'diagnosedAt': null,
            'diagnosedBy': null,
            'notes': null,
          }),
          status: 'pending',
          createdAt: timestamp,
        ),
      );
    }

    setUp(() {
      timestamp = DateTime.utc(2026, 10, 24, 5, 30);
    });

    test('does not push when there is no session', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => null);

      await expectLater(syncManager.pushChanges(), throwsA(isA<StateError>()));

      verifyNever(
        () => conditionRemoteDataSource.createCondition(
          id: any(named: 'id'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      );
    });

    test('creates remotely and removes outbox entry on success', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition();
      await addOutboxEntry();

      when(
        () => conditionRemoteDataSource.createCondition(
          id: 'condition-1',
          name: 'Asthma',
          status: 'active',
          diagnosedAt: null,
          diagnosedBy: null,
          notes: null,
        ),
      ).thenAnswer(
        (_) async => ConditionModel(
          id: 'condition-1',
          userId: session.userId,
          name: 'Asthma',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await syncManager.pushChanges();

      final entry = await database.outboxDao.getById('outbox-1');

      expect(entry, isNull);

      verify(
        () => conditionRemoteDataSource.createCondition(
          id: 'condition-1',
          name: 'Asthma',
          status: 'active',
          diagnosedAt: null,
          diagnosedBy: null,
          notes: null,
        ),
      ).called(1);
    });

    test('keeps failed entry and increments attempts', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition();
      await addOutboxEntry();

      when(
        () => conditionRemoteDataSource.createCondition(
          id: 'condition-1',
          name: 'Asthma',
          status: 'active',
          diagnosedAt: null,
          diagnosedBy: null,
          notes: null,
        ),
      ).thenThrow(Exception('Network unavailable'));

      await syncManager.pushChanges();

      final entry = await database.outboxDao.getById('outbox-1');

      expect(entry, isNotNull);
      expect(entry!.status, 'pending');
      expect(entry.attempts, 1);
      expect(entry.lastError, contains('Network unavailable'));
    });

    test('does not push a condition owned by another user', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition(userId: 'another-user');
      await addOutboxEntry();

      await syncManager.pushChanges();

      final entry = await database.outboxDao.getById('outbox-1');

      expect(entry, isNotNull);
      expect(entry!.attempts, 1);

      verifyNever(
        () => conditionRemoteDataSource.createCondition(
          id: any(named: 'id'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      );
    });

    test('does not push when payload user differs from session', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition();
      await addOutboxEntry(payloadUserId: 'another-user');

      await syncManager.pushChanges();

      final entry = await database.outboxDao.getById('outbox-1');

      expect(entry, isNotNull);
      expect(entry!.attempts, 1);

      verifyNever(
        () => conditionRemoteDataSource.createCondition(
          id: any(named: 'id'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      );
    });

    test('updates remotely and removes outbox entry on success', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition();
      await addOutboxEntry(operation: 'update');

      when(
        () => conditionRemoteDataSource.updateCondition(
          id: 'condition-1',
          name: 'Asthma',
          status: 'active',
          diagnosedAt: null,
          diagnosedBy: null,
          notes: null,
        ),
      ).thenAnswer(
        (_) async => ConditionModel(
          id: 'condition-1',
          userId: session.userId,
          name: 'Asthma',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await syncManager.pushChanges();

      expect(await database.outboxDao.getById('outbox-1'), isNull);

      verify(
        () => conditionRemoteDataSource.updateCondition(
          id: 'condition-1',
          name: 'Asthma',
          status: 'active',
          diagnosedAt: null,
          diagnosedBy: null,
          notes: null,
        ),
      ).called(1);
    });

    test('deletes remotely and removes outbox entry on success', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      await seedUserAndCondition(deleted: true);

      await database.outboxDao.insertOutbox(
        OutboxCompanion.insert(
          id: 'outbox-1',
          userId: drift.Value(session.userId),
          entityType: 'condition',
          entityId: 'condition-1',
          operation: 'delete',
          payload: jsonEncode({'userId': session.userId}),
          status: 'pending',
          createdAt: timestamp,
        ),
      );

      when(() => conditionRemoteDataSource.deleteCondition('condition-1'))
          .thenAnswer((_) async {});

      await syncManager.pushChanges();

      expect(await database.outboxDao.getById('outbox-1'), isNull);

      verify(() => conditionRemoteDataSource.deleteCondition('condition-1'))
          .called(1);
    });
    test(
      'does not delete remotely when payload user differs from session',
      () async {
        when(() => getCurrentSession()).thenAnswer((_) async => session);

        await seedUserAndCondition(deleted: true);

        await database.outboxDao.insertOutbox(
          OutboxCompanion.insert(
            id: 'outbox-wrong-user',
            userId: const drift.Value('user-1'),
            entityType: 'condition',
            entityId: 'condition-1',
            operation: 'delete',
            payload: jsonEncode({'userId': 'another-user'}),
            status: 'pending',
            createdAt: timestamp,
          ),
        );

        await syncManager.pushChanges();

        final entry = await database.outboxDao.getById('outbox-wrong-user');

        expect(entry, isNotNull);
        expect(entry!.attempts, 1);

        verifyNever(
          () => conditionRemoteDataSource.deleteCondition('condition-1'),
        );
      },
    );

    group('pushChanges medications', () {
      Future<void> seedUserAndMedication({
        String medicationId = 'medication-1',
        String userId = 'user-1',
        bool deleted = false,
      }) async {
        await database.usersDao.insertUser(
          UsersCompanion.insert(
            id: userId,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

        await database.medicationsDao.insertMedication(
          MedicationsCompanion.insert(
            id: medicationId,
            userId: userId,
            name: 'Aspirin',
            genericName: const drift.Value('Acetylsalicylic acid'),
            dosage: const drift.Value('100'),
            unit: const drift.Value('mg'),
            frequencyType: 'daily',
            frequencyValue: const drift.Value('1'),
            route: 'oral',
            status: 'active',
            prescribedBy: const drift.Value('Doctor'),
            notes: const drift.Value('Test medication'),
            createdAt: timestamp,
            updatedAt: timestamp,
            deletedAt: deleted
                ? drift.Value(timestamp)
                : const drift.Value.absent(),
          ),
        );
      }

      Future<void> addMedicationOutboxEntry({
        String id = 'outbox-medication-1',
        String entityId = 'medication-1',
        String operation = 'create',
        String userId = 'user-1',
        String payloadUserId = 'user-1',
        String name = 'Aspirin',
        String genericName = 'Acetylsalicylic acid',
        String dosage = '100',
        String unit = 'mg',
        String frequencyType = 'daily',
        String frequencyValue = '1',
        String route = 'oral',
        String status = 'active',
        String prescribedBy = 'Doctor',
        String notes = 'Test medication',
        String? startDate,
        String? endDate,
      }) async {
        await database.outboxDao.insertOutbox(
          OutboxCompanion.insert(
            id: id,
            userId: drift.Value(userId),
            entityType: 'medication',
            entityId: entityId,
            operation: operation,
            payload: jsonEncode({
              'userId': payloadUserId,
              'name': name,
              'genericName': genericName,
              'dosage': dosage,
              'unit': unit,
              'frequencyType': frequencyType,
              'frequencyValue': frequencyValue,
              'route': route,
              'startDate': startDate,
              'endDate': endDate,
              'status': status,
              'prescribedBy': prescribedBy,
              'notes': notes,
            }),
            status: 'pending',
            createdAt: timestamp,
          ),
        );
      }

      test('creates medication remotely and removes outbox entry on success',
              () async {
            when(() => getCurrentSession()).thenAnswer((_) async => session);

            await seedUserAndMedication();
            await addMedicationOutboxEntry();

            when(
                  () => medicationRemoteDataSource.createMedication(
                id: 'medication-1',
                name: 'Aspirin',
                genericName: 'Acetylsalicylic acid',
                dosage: '100',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '1',
                route: 'oral',
                startDate: null,
                endDate: null,
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Test medication',
              ),
            ).thenAnswer(
                  (_) async => MedicationModel(
                id: 'medication-1',
                userId: session.userId,
                name: 'Aspirin',
                genericName: 'Acetylsalicylic acid',
                dosage: '100',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '1',
                route: 'oral',
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Test medication',
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

            await syncManager.pushChanges();

            expect(
              await database.outboxDao.getById('outbox-medication-1'),
              isNull,
            );

            verify(
                  () => medicationRemoteDataSource.createMedication(
                id: 'medication-1',
                name: 'Aspirin',
                genericName: 'Acetylsalicylic acid',
                dosage: '100',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '1',
                route: 'oral',
                startDate: null,
                endDate: null,
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Test medication',
              ),
            ).called(1);
          });

      test(
        'does not push subsequent operations when an earlier operation fails',
            () async {
          when(() => getCurrentSession()).thenAnswer((_) async => session);

          await seedUserAndMedication();

          // First event: create
          await addMedicationOutboxEntry(
            id: 'outbox-medication-create',
            operation: 'create',
          );

          // Second event: update
          await addMedicationOutboxEntry(
            id: 'outbox-medication-update',
            operation: 'update',
            name: 'Aspirin Updated',
            dosage: '200',
            frequencyValue: '2',
          );

          when(
                () => medicationRemoteDataSource.createMedication(
              id: 'medication-1',
              name: 'Aspirin',
              genericName: 'Acetylsalicylic acid',
              dosage: '100',
              unit: 'mg',
              frequencyType: 'daily',
              frequencyValue: '1',
              route: 'oral',
              startDate: null,
              endDate: null,
              status: 'active',
              prescribedBy: 'Doctor',
              notes: 'Test medication',
            ),
          ).thenThrow(Exception('Network unavailable'));

          await syncManager.pushChanges();

          final createEntry = await database.outboxDao.getById(
            'outbox-medication-create',
          );

          final updateEntry = await database.outboxDao.getById(
            'outbox-medication-update',
          );

          // Create failed and remains in Outbox.
          expect(createEntry, isNotNull);
          expect(createEntry!.attempts, 1);

          // Update was blocked and remains untouched.
          expect(updateEntry, isNotNull);
          expect(updateEntry!.attempts, 0);
          expect(updateEntry.status, 'pending');

          verify(
                () => medicationRemoteDataSource.createMedication(
              id: 'medication-1',
              name: 'Aspirin',
              genericName: 'Acetylsalicylic acid',
              dosage: '100',
              unit: 'mg',
              frequencyType: 'daily',
              frequencyValue: '1',
              route: 'oral',
              startDate: null,
              endDate: null,
              status: 'active',
              prescribedBy: 'Doctor',
              notes: 'Test medication',
            ),
          ).called(1);

          verifyNever(
                () => medicationRemoteDataSource.updateMedication(
              id: any(named: 'id'),
              name: any(named: 'name'),
              genericName: any(named: 'genericName'),
              dosage: any(named: 'dosage'),
              unit: any(named: 'unit'),
              frequencyType: any(named: 'frequencyType'),
              frequencyValue: any(named: 'frequencyValue'),
              route: any(named: 'route'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              status: any(named: 'status'),
              prescribedBy: any(named: 'prescribedBy'),
              notes: any(named: 'notes'),
            ),
          );
        },
      );

      test(
        'keeps failed medication entry and increments attempts',
            () async {
          when(() => getCurrentSession()).thenAnswer((_) async => session);

          await seedUserAndMedication();
          await addMedicationOutboxEntry();

          when(
                () => medicationRemoteDataSource.createMedication(
              id: 'medication-1',
              name: 'Aspirin',
              genericName: 'Acetylsalicylic acid',
              dosage: '100',
              unit: 'mg',
              frequencyType: 'daily',
              frequencyValue: '1',
              route: 'oral',
              startDate: null,
              endDate: null,
              status: 'active',
              prescribedBy: 'Doctor',
              notes: 'Test medication',
            ),
          ).thenThrow(Exception('Network unavailable'));

          await syncManager.pushChanges();

          final entry = await database.outboxDao.getById(
            'outbox-medication-1',
          );

          expect(entry, isNotNull);
          expect(entry!.status, 'pending');
          expect(entry.attempts, 1);
          expect(entry.lastError, contains('Network unavailable'));
        },
      );

      test('updates medication remotely and removes outbox entry on success',
              () async {
            when(() => getCurrentSession()).thenAnswer((_) async => session);

            await seedUserAndMedication();
            await addMedicationOutboxEntry(
              operation: 'update',
              name: 'Aspirin Updated',
              dosage: '200',
              frequencyValue: '2',
              notes: 'Updated medication',
            );

            when(
                  () => medicationRemoteDataSource.updateMedication(
                id: 'medication-1',
                name: 'Aspirin Updated',
                genericName: 'Acetylsalicylic acid',
                dosage: '200',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '2',
                route: 'oral',
                startDate: null,
                endDate: null,
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Updated medication',
              ),
            ).thenAnswer(
                  (_) async => MedicationModel(
                id: 'medication-1',
                userId: session.userId,
                name: 'Aspirin Updated',
                genericName: 'Acetylsalicylic acid',
                dosage: '200',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '2',
                route: 'oral',
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Updated medication',
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

            await syncManager.pushChanges();

            expect(
              await database.outboxDao.getById('outbox-medication-1'),
              isNull,
            );

            verify(
                  () => medicationRemoteDataSource.updateMedication(
                id: 'medication-1',
                name: 'Aspirin Updated',
                genericName: 'Acetylsalicylic acid',
                dosage: '200',
                unit: 'mg',
                frequencyType: 'daily',
                frequencyValue: '2',
                route: 'oral',
                startDate: null,
                endDate: null,
                status: 'active',
                prescribedBy: 'Doctor',
                notes: 'Updated medication',
              ),
            ).called(1);
          });

      test('deletes medication remotely and removes outbox entry on success',
              () async {
            when(() => getCurrentSession()).thenAnswer((_) async => session);

            await seedUserAndMedication(deleted: true);

            await database.outboxDao.insertOutbox(
              OutboxCompanion.insert(
                id: 'outbox-medication-delete',
                userId: drift.Value(session.userId),
                entityType: 'medication',
                entityId: 'medication-1',
                operation: 'delete',
                payload: jsonEncode({
                  'userId': session.userId,
                }),
                status: 'pending',
                createdAt: timestamp,
              ),
            );

            when(
                  () => medicationRemoteDataSource.deleteMedication('medication-1'),
            ).thenAnswer((_) async {});

            await syncManager.pushChanges();

            expect(
              await database.outboxDao.getById('outbox-medication-delete'),
              isNull,
            );

            verify(
                  () => medicationRemoteDataSource.deleteMedication('medication-1'),
            ).called(1);
          });

      test(
        'does not push a medication owned by another user',
            () async {
          when(() => getCurrentSession()).thenAnswer((_) async => session);

          await seedUserAndMedication(
            userId: 'another-user',
          );

          await addMedicationOutboxEntry();

          await syncManager.pushChanges();

          final entry = await database.outboxDao.getById(
            'outbox-medication-1',
          );

          expect(entry, isNotNull);
          expect(entry!.attempts, 1);

          verifyNever(
                () => medicationRemoteDataSource.createMedication(
              id: any(named: 'id'),
              name: any(named: 'name'),
              genericName: any(named: 'genericName'),
              dosage: any(named: 'dosage'),
              unit: any(named: 'unit'),
              frequencyType: any(named: 'frequencyType'),
              frequencyValue: any(named: 'frequencyValue'),
              route: any(named: 'route'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              status: any(named: 'status'),
              prescribedBy: any(named: 'prescribedBy'),
              notes: any(named: 'notes'),
            ),
          );
        },
      );

      test(
        'does not push when medication payload user differs from session',
            () async {
          when(() => getCurrentSession()).thenAnswer((_) async => session);

          await seedUserAndMedication();

          await addMedicationOutboxEntry(
            payloadUserId: 'another-user',
          );

          await syncManager.pushChanges();

          final entry = await database.outboxDao.getById(
            'outbox-medication-1',
          );

          expect(entry, isNotNull);
          expect(entry!.attempts, 1);

          verifyNever(
                () => medicationRemoteDataSource.createMedication(
              id: any(named: 'id'),
              name: any(named: 'name'),
              genericName: any(named: 'genericName'),
              dosage: any(named: 'dosage'),
              unit: any(named: 'unit'),
              frequencyType: any(named: 'frequencyType'),
              frequencyValue: any(named: 'frequencyValue'),
              route: any(named: 'route'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              status: any(named: 'status'),
              prescribedBy: any(named: 'prescribedBy'),
              notes: any(named: 'notes'),
            ),
          );
        },
      );
    });

    group('pullChanges medications', () {
      test('applies a remote medication and saves the cursor', () async {
        when(() => getCurrentSession()).thenAnswer((_) async => session);

        final timestamp = DateTime.utc(2026, 10, 24, 5, 30);
        const newCursor = '2026-10-24T06:00:00.000Z';

        await database.usersDao.insertUser(
          UsersCompanion.insert(
            id: session.userId,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

        final syncResponse = SyncResponseModel(
          cursor: newCursor,
          changes: [
            SyncChangeModel(
              entity: 'medication',
              operation: 'created',
              id: 'medication-1',
              timestamp: timestamp,
              data: {
                'id': 'medication-1',
                'userId': session.userId,
                'name': 'Aspirin',
                'genericName': 'Acetylsalicylic acid',
                'dosage': '100',
                'unit': 'mg',
                'frequencyType': 'daily',
                'frequencyValue': '1',
                'route': 'oral',
                'startDate': null,
                'endDate': null,
                'status': 'active',
                'prescribedBy': null,
                'notes': 'Remote medication',
                'createdAt': timestamp.toIso8601String(),
                'updatedAt': timestamp.toIso8601String(),
                'deletedAt': null,
              },
            ),
          ],
        );

        when(() => remoteDataSource.getChanges(cursor: null))
            .thenAnswer((_) async => syncResponse);

        await syncManager.pullChanges();

        final medication = await database.medicationsDao
            .getMedicationById('medication-1');

        final cursor = await database.syncCursorDao.getByUserId(
          session.userId,
        );

        expect(medication, isNotNull);
        expect(medication!.name, 'Aspirin');
        expect(medication.userId, session.userId);
        expect(medication.frequencyType, 'daily');
        expect(cursor?.cursor, newCursor);

        final outboxEntries = await database.outboxDao.getPendingEntries(
          userId: session.userId,
        );

        expect(outboxEntries, isEmpty);
      });
    });

    test('applies a remote medication update', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      final timestamp = DateTime.utc(2026, 10, 24, 5, 30);

      await database.usersDao.insertUser(
        UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await database.medicationsDao.insertMedication(
        MedicationsCompanion.insert(
          id: 'medication-1',
          userId: session.userId,
          name: 'Old Name',
          frequencyType: 'daily',
          route: 'oral',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      final syncResponse = SyncResponseModel(
        cursor: '2026-10-24T06:00:00.000Z',
        changes: [
          SyncChangeModel(
            entity: 'medication',
            operation: 'updated',
            id: 'medication-1',
            timestamp: timestamp.add(const Duration(minutes: 1)),
            data: {
              'id': 'medication-1',
              'userId': session.userId,
              'name': 'Updated Name',
              'genericName': null,
              'dosage': '200',
              'unit': 'mg',
              'frequencyType': 'daily',
              'frequencyValue': '2',
              'route': 'oral',
              'startDate': null,
              'endDate': null,
              'status': 'active',
              'prescribedBy': null,
              'notes': null,
              'createdAt': timestamp.toIso8601String(),
              'updatedAt': timestamp.add(const Duration(minutes: 1)).toIso8601String(),
              'deletedAt': null,
            },
          ),
        ],
      );

      when(() => remoteDataSource.getChanges(cursor: null))
          .thenAnswer((_) async => syncResponse);

      await syncManager.pullChanges();

      final medication = await database.medicationsDao
          .getMedicationById('medication-1');

      expect(medication, isNotNull);
      expect(medication!.name, 'Updated Name');
      expect(medication.dosage, '200');
      expect(medication.frequencyValue, '2');
    });

    test('applies a remote medication deletion', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      final timestamp = DateTime.utc(2026, 10, 24, 5, 30);

      await database.usersDao.insertUser(
        UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await database.medicationsDao.insertMedication(
        MedicationsCompanion.insert(
          id: 'medication-1',
          userId: session.userId,
          name: 'Aspirin',
          frequencyType: 'daily',
          route: 'oral',
          status: 'active',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      final deletedAt = timestamp.add(const Duration(minutes: 1));

      final syncResponse = SyncResponseModel(
        cursor: '2026-10-24T06:00:00.000Z',
        changes: [
          SyncChangeModel(
            entity: 'medication',
            operation: 'deleted',
            id: 'medication-1',
            data: null,
            timestamp: deletedAt,
          ),
        ],
      );

      when(() => remoteDataSource.getChanges(cursor: null))
          .thenAnswer((_) async => syncResponse);

      await syncManager.pullChanges();

      final medication = await database.medicationsDao
          .getMedicationById('medication-1');

      final rows = await database.select(database.medications).get();

      expect(medication, isNull);
      expect(rows, hasLength(1));
      expect(
        rows.single.deletedAt?.toUtc(),
        deletedAt.toUtc(),
      );

      final outboxEntries = await database.outboxDao.getPendingEntries(
        userId: session.userId,
      );

      expect(outboxEntries, isEmpty);
    });

    test('rejects a remote medication belonging to another user', () async {
      when(() => getCurrentSession()).thenAnswer((_) async => session);

      final timestamp = DateTime.utc(2026, 10, 24, 5, 30);

      await database.usersDao.insertUser(
        UsersCompanion.insert(
          id: session.userId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      final syncResponse = SyncResponseModel(
        cursor: '2026-10-24T06:00:00.000Z',
        changes: [
          SyncChangeModel(
            entity: 'medication',
            operation: 'created',
            id: 'medication-1',
            timestamp: timestamp,
            data: {
              'id': 'medication-1',
              'userId': 'another-user',
              'name': 'Aspirin',
              'frequencyType': 'daily',
              'route': 'oral',
              'status': 'active',
              'createdAt': timestamp.toIso8601String(),
              'updatedAt': timestamp.toIso8601String(),
              'deletedAt': null,
            },
          ),
        ],
      );

      when(() => remoteDataSource.getChanges(cursor: null))
          .thenAnswer((_) async => syncResponse);

      await expectLater(
        syncManager.pullChanges(),
        throwsA(isA<FormatException>()),
      );

      final medication = await database.medicationsDao
          .getMedicationById('medication-1');

      final cursor = await database.syncCursorDao.getByUserId(
        session.userId,
      );

      expect(medication, isNull);
      expect(cursor, isNull);
    });
  });
}
