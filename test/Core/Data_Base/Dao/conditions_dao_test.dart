import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conditions_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

void main() {
  late AppDatabase database;
  late UsersDao usersDao;
  late ConditionsDao conditionsDao;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conditionsDao = ConditionsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  const userId = 'user-1';
  const conditionId = 'condition-1';

  final now = DateTime(2026, 1, 1);

  Future<void> createUser() {
    return usersDao.insertUser(
      UsersCompanion.insert(
        id: userId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  ConditionsCompanion createCondition({
    String id = conditionId,
    String name = 'Diabetes',
    String status = 'active',
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ConditionsCompanion.insert(
      id: id,
      userId: userId,
      name: name,
      status: status,
      diagnosedAt: drift.Value(diagnosedAt),
      diagnosedBy: drift.Value(diagnosedBy),
      notes: drift.Value(notes),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      deletedAt: drift.Value(deletedAt),
    );
  }

  test(
    'insertCondition and getConditionById should work',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      final condition = await conditionsDao.getConditionById(
        conditionId,
      );

      expect(condition, isNotNull);
      expect(condition!.id, conditionId);
      expect(condition.userId, userId);
      expect(condition.name, 'Diabetes');
      expect(condition.status, 'active');
    },
  );

  test(
    'getConditionById should return null when condition does not exist',
        () async {
      final condition = await conditionsDao.getConditionById(
        'not-found',
      );

      expect(condition, isNull);
    },
  );

  test(
    'getConditionsByUserId should return user active conditions',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(
          id: 'condition-1',
          name: 'Diabetes',
        ),
      );

      await conditionsDao.insertCondition(
        createCondition(
          id: 'condition-2',
          name: 'Hypertension',
        ),
      );

      final conditions =
      await conditionsDao.getConditionsByUserId(userId);

      expect(conditions, hasLength(2));
      expect(conditions[0].name, 'Diabetes');
      expect(conditions[1].name, 'Hypertension');
    },
  );

  test(
    'getConditionsByUserId should not return soft deleted conditions',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      await conditionsDao.deleteCondition(conditionId);

      final conditions =
      await conditionsDao.getConditionsByUserId(userId);

      expect(conditions, isEmpty);
    },
  );

  test(
    'getConditionById should not return soft deleted condition',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      await conditionsDao.deleteCondition(conditionId);

      final condition = await conditionsDao.getConditionById(
        conditionId,
      );

      expect(condition, isNull);
    },
  );

  test(
    'deleteCondition should perform soft delete',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      final deletedRows = await conditionsDao.deleteCondition(
        conditionId,
      );

      expect(deletedRows, 1);

      final condition = await (conditionsDao.select(
        conditionsDao.conditions,
      )..where(
            (condition) => condition.id.equals(conditionId),
      ))
          .getSingleOrNull();

      expect(condition, isNotNull);
      expect(condition!.deletedAt, isNotNull);
    },
  );

  test(
    'updateCondition should update the condition',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      final updatedTime = DateTime(2026, 2, 1);

      final updatedCondition = createCondition(
        name: 'Updated Diabetes',
        status: 'resolved',
        notes: 'Condition updated',
        updatedAt: updatedTime,
      );

      final result = await conditionsDao.updateCondition(
        updatedCondition,
      );

      expect(result, isTrue);

      final condition = await conditionsDao.getConditionById(
        conditionId,
      );

      expect(condition, isNotNull);
      expect(condition!.name, 'Updated Diabetes');
      expect(condition.status, 'resolved');
      expect(condition.notes, 'Condition updated');
      expect(condition.updatedAt, updatedTime);
    },
  );

  test(
    'insertCondition should fail when userId does not exist',
        () async {
      final condition = ConditionsCompanion.insert(
        id: conditionId,
        userId: 'non-existing-user',
        name: 'Diabetes',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      expect(
            () => conditionsDao.insertCondition(condition),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'deleting a user should cascade delete its conditions',
        () async {
      await createUser();

      await conditionsDao.insertCondition(
        createCondition(),
      );

      expect(
        await conditionsDao.getConditionById(conditionId),
        isNotNull,
      );

      await usersDao.deleteUser(userId);

      expect(
        await conditionsDao.getConditionById(conditionId),
        isNull,
      );

      final condition = await (conditionsDao.select(
        conditionsDao.conditions,
      )..where(
            (condition) => condition.id.equals(conditionId),
      ))
          .getSingleOrNull();

      expect(condition, isNull);
    },
  );
}