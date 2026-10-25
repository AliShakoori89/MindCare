import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_change_model.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_response_model.dart';
import 'package:mind_care/Core/Sync/Domain/Services/sync_manager.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';
import 'package:mind_care/Features/Authentication/Domain/Use_Cases/get_current_session.dart';

class MockSyncRemoteDataSource extends Mock
    implements SyncRemoteDataSource {}

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

void main() {
  late AppDatabase database;
  late MockSyncRemoteDataSource remoteDataSource;
  late MockGetCurrentSession getCurrentSession;
  late SyncManager syncManager;

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

    syncManager = SyncManager(
      db: database,
      remoteDataSource: remoteDataSource,
      getCurrentSession: getCurrentSession,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('does not request changes when there is no session', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => null);

    await expectLater(
      syncManager.pullChanges(),
      throwsA(isA<StateError>()),
    );

    verifyNever(() => remoteDataSource.getChanges(cursor: any(named: 'cursor')));
  });

  test('requests changes without cursor when no cursor is saved', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);
    when(
      () => remoteDataSource.getChanges(cursor: null),
    ).thenAnswer((_) async => response);

    await syncManager.pullChanges();

    verify(() => remoteDataSource.getChanges(cursor: null)).called(1);
  });

  test('requests changes using the saved cursor', () async {
    when(() => getCurrentSession()).thenAnswer((_) async => session);
    when(
      () => remoteDataSource.getChanges(
        cursor: '2026-10-24T05:00:00.000Z',
      ),
    ).thenAnswer((_) async => response);

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
      () => remoteDataSource.getChanges(
        cursor: '2026-10-24T05:00:00.000Z',
      ),
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

    when(
          () => remoteDataSource.getChanges(cursor: null),
    ).thenAnswer((_) async => syncResponse);

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

    when(
          () => remoteDataSource.getChanges(cursor: null),
    ).thenAnswer((_) async => syncResponse);

    await syncManager.pullChanges();

    final condition = await database.conditionsDao.getConditionById(
      'condition-1',
    );
    final cursor = await database.syncCursorDao.getByUserId(
      session.userId,
    );

    expect(condition, isNull);
    expect(cursor?.cursor, newCursor);

    final rows = await database.select(database.conditions).get();
    expect(rows, hasLength(1));
    expect(rows.single.deletedAt, isNotNull);
  });


  test('rolls back changes and does not advance cursor on unsupported entity',
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

        when(
              () => remoteDataSource.getChanges(cursor: initialCursor),
        ).thenAnswer((_) async => syncResponse);

        await expectLater(
          syncManager.pullChanges(),
          throwsA(isA<UnsupportedError>()),
        );

        final condition = await database.conditionsDao.getConditionById(
          'condition-1',
        );
        final cursor = await database.syncCursorDao.getByUserId(
          session.userId,
        );

        expect(condition, isNull);
        expect(cursor?.cursor, initialCursor);
      });

}
