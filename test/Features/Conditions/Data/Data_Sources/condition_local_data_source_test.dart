import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source_impl.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late ConditionLocalDataSourceImpl dataSource;

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);
  final diagnosedAt = DateTime(2025, 1, 1);

  ConditionsCompanion createCondition({
    String id = 'condition-1',
    String userId = 'user-1',
    String name = 'Diabetes',
    String status = 'active',
    DateTime? deletedAt,
  }) {
    return ConditionsCompanion(
      id: drift.Value(id),
      userId: drift.Value(userId),
      name: drift.Value(name),
      status: drift.Value(status),
      diagnosedAt: drift.Value(diagnosedAt),
      diagnosedBy: const drift.Value('Dr. Test'),
      notes: const drift.Value('Test condition'),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      deletedAt: drift.Value(deletedAt),
    );
  }

  Future<void> createUser({
    String id = 'user-1',
  }) async {
    await usersDao.insertUser(
      UsersCompanion.insert(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    usersDao = UsersDao(database);
    dataSource = ConditionLocalDataSourceImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('insertCondition', () {
    test('should insert condition into local database', () async {

      await createUser();

      final condition = createCondition();

      await dataSource.insertCondition(condition);

      final result = await dataSource.getConditionById('condition-1');

      expect(result, isNotNull);
      expect(result!.id, 'condition-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Diabetes');
      expect(result.status, 'active');
    });

    test('should create pending outbox entry when inserting condition', () async {
      await createUser();

      final condition = createCondition();

      await dataSource.insertCondition(condition);

      final entries = await database.outboxDao.getPendingEntries();

      expect(entries, hasLength(1));

      final entry = entries.first;

      expect(entry.entityType, 'condition');
      expect(entry.entityId, 'condition-1');
      expect(entry.operation, 'create');
      expect(entry.status, 'pending');
      expect(entry.attempts, 0);
      expect(entry.lastError, isNull);

      expect(
        entry.payload,
        contains('"name":"Diabetes"'),
      );
      expect(
        entry.payload,
        contains('"status":"active"'),
      );
      expect(
        entry.payload,
        contains('"diagnosedBy":"Dr. Test"'),
      );
      expect(
        entry.payload,
        contains('"notes":"Test condition"'),
      );
    });
  });

  group('getConditionById', () {
    test('should return condition when it exists', () async {
      await createUser();
      await dataSource.insertCondition(createCondition());

      final result = await dataSource.getConditionById('condition-1');

      expect(result, isNotNull);
      expect(result!.id, 'condition-1');
    });

    test('should return null when condition does not exist', () async {
      await createUser();
      final result = await dataSource.getConditionById('not-found');

      expect(result, isNull);
    });

    test('should not return soft-deleted condition', () async {
      await createUser();
      await dataSource.insertCondition(
        createCondition(
          deletedAt: DateTime(2026, 1, 2),
        ),
      );

      final result = await dataSource.getConditionById('condition-1');

      expect(result, isNull);
    });
  });

  group('getConditionsByUserId', () {
    test('should return conditions belonging to user', () async {
      await createUser();
      await createUser(id: 'user-2');

      await dataSource.insertCondition(
        createCondition(id: 'condition-1'),
      );

      await dataSource.insertCondition(
        createCondition(
          id: 'condition-2',
          name: 'Hypertension',
        ),
      );

      await dataSource.insertCondition(
        createCondition(
          id: 'condition-3',
          userId: 'user-2',
        ),
      );

      final result = await dataSource.getConditionsByUserId('user-1');

      expect(result, hasLength(2));
      expect(
        result.map((condition) => condition.id),
        containsAll(['condition-1', 'condition-2']),
      );
    });

    test('should return empty list when user has no conditions', () async {
      await createUser();
      final result = await dataSource.getConditionsByUserId('user-1');

      expect(result, isEmpty);
    });

    test('should not return soft-deleted conditions', () async {
      await createUser();
      await dataSource.insertCondition(
        createCondition(id: 'condition-1'),
      );

      await dataSource.insertCondition(
        createCondition(
          id: 'condition-2',
          name: 'Hypertension',
          deletedAt: DateTime(2026, 1, 2),
        ),
      );

      final result = await dataSource.getConditionsByUserId('user-1');

      expect(result, hasLength(1));
      expect(result.first.id, 'condition-1');
    });
  });

  group('updateCondition', () {
    test('should update existing condition', () async {
      await createUser();
      await dataSource.insertCondition(
        createCondition(),
      );

      final updatedCondition = createCondition(
        name: 'Updated Diabetes',
        status: 'inactive',
      );

      final result = await dataSource.updateCondition(updatedCondition);

      expect(result, isTrue);

      final condition =
      await dataSource.getConditionById('condition-1');

      expect(condition, isNotNull);
      expect(condition!.name, 'Updated Diabetes');
      expect(condition.status, 'inactive');
    });

    test('should create pending outbox entry when updating condition',
            () async {
          await createUser();

          await dataSource.insertCondition(
            createCondition(),
          );

          final updatedCondition = createCondition(
            name: 'Updated Diabetes',
            status: 'inactive',
          );

          await dataSource.updateCondition(updatedCondition);

          final entries = await database.outboxDao.getPendingEntries();

          expect(entries, hasLength(2));

          final entry = entries.last;

          expect(entry.entityType, 'condition');
          expect(entry.entityId, 'condition-1');
          expect(entry.operation, 'update');
          expect(entry.status, 'pending');
          expect(entry.attempts, 0);
          expect(entry.lastError, isNull);

          expect(
            entry.payload,
            contains('"name":"Updated Diabetes"'),
          );
          expect(
            entry.payload,
            contains('"status":"inactive"'),
          );
        });

  });

  group('deleteCondition', () {
    test('should soft delete existing condition', () async {
      await createUser();
      await dataSource.insertCondition(
        createCondition(),
      );

      final result = await dataSource.deleteCondition('condition-1');

      expect(result, 1);

      final condition =
      await dataSource.getConditionById('condition-1');

      expect(condition, isNull);
    });

    test('should return zero when condition does not exist', () async {
      await createUser();
      final result = await dataSource.deleteCondition('not-found');

      expect(result, 0);
    });

    test('should create pending outbox entry when deleting condition',
            () async {
          await createUser();

          await dataSource.insertCondition(
            createCondition(),
          );

          final result = await dataSource.deleteCondition('condition-1');

          expect(result, 1);

          final entries = await database.outboxDao.getPendingEntries();

          expect(entries, hasLength(2));

          final entry = entries.last;

          expect(entry.entityType, 'condition');
          expect(entry.entityId, 'condition-1');
          expect(entry.operation, 'delete');
          expect(entry.status, 'pending');
          expect(entry.attempts, 0);
          expect(entry.lastError, isNull);
          expect(entry.payload, '{}');
        });
  });
}