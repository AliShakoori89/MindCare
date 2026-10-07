import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/conditions_dao.dart';
import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source_impl.dart';
import 'package:mind_care/Features/Conditions/Data/Repositories/condition_repository_impl.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart'
as domain;

void main() {
  late db.AppDatabase database;
  late UsersDao usersDao;
  late ConditionsDao conditionsDao;
  late ConditionLocalDataSource localDataSource;
  late ConditionRepositoryImpl repository;

  const userId = 'user-1';
  const conditionId = 'condition-1';

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  domain.Condition createCondition({
    String name = 'Diabetes',
    String status = 'active',
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
    DateTime? updatedAt,
  }) {
    return domain.Condition(
      id: conditionId,
      userId: userId,
      name: name,
      status: status,
      diagnosedAt: diagnosedAt ?? DateTime(2025, 6, 1),
      diagnosedBy: diagnosedBy ?? 'Dr. Ahmadi',
      notes: notes ?? 'Test condition',
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime(2026, 1, 1),
      deletedAt: null,
    );
  }

  Future<void> createUser() async {
    await usersDao.insertUser(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    usersDao = UsersDao(database);
    conditionsDao = ConditionsDao(database);

    localDataSource = ConditionLocalDataSourceImpl(
      conditionsDao,
    );

    repository = ConditionRepositoryImpl(
      localDataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createCondition should persist the condition',
        () async {
      await createUser();

      final condition = createCondition();

      await repository.createCondition(condition);

      final result = await repository.getConditionById(
        conditionId,
      );

      expect(result, isNotNull);
      expect(result?.id, conditionId);
      expect(result?.userId, userId);
      expect(result?.name, 'Diabetes');
      expect(result?.status, 'active');
      expect(result?.diagnosedBy, 'Dr. Ahmadi');
    },
  );

  test(
    'getConditionById should return null when condition does not exist',
        () async {
      final result = await repository.getConditionById(
        conditionId,
      );

      expect(result, isNull);
    },
  );

  test(
    'getConditionsByUserId should return user conditions',
        () async {
      await createUser();

      await repository.createCondition(
        createCondition(),
      );

      final result = await repository.getConditionsByUserId(
        userId,
      );

      expect(result, hasLength(1));
      expect(result.first.id, conditionId);
      expect(result.first.userId, userId);
      expect(result.first.name, 'Diabetes');
    },
  );

  test(
    'getConditionsByUserId should return empty list when user has no conditions',
        () async {
      await createUser();

      final result = await repository.getConditionsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );

  test(
    'updateCondition should update the condition',
        () async {
      await createUser();

      await repository.createCondition(
        createCondition(),
      );

      final updatedCondition = createCondition(
        name: 'Updated Diabetes',
        status: 'resolved',
        diagnosedBy: 'Dr. Ahmadi',
        notes: 'Condition has been updated.',
        updatedAt: DateTime(2026, 2, 1),
      );

      await repository.updateCondition(
        updatedCondition,
      );

      final result = await repository.getConditionById(
        conditionId,
      );

      expect(result, isNotNull);
      expect(result?.name, 'Updated Diabetes');
      expect(result?.status, 'resolved');
      expect(result?.notes, 'Condition has been updated.');
      expect(
        result?.updatedAt,
        DateTime(2026, 2, 1),
      );
    },
  );

  test(
    'deleteCondition should soft delete the condition',
        () async {
      await createUser();

      await repository.createCondition(
        createCondition(),
      );

      await repository.deleteCondition(
        conditionId,
      );

      final result = await repository.getConditionById(
        conditionId,
      );

      expect(result, isNull);
    },
  );

  test(
    'deleted condition should not be returned by getConditionsByUserId',
        () async {
      await createUser();

      await repository.createCondition(
        createCondition(),
      );

      await repository.deleteCondition(
        conditionId,
      );

      final result = await repository.getConditionsByUserId(
        userId,
      );

      expect(result, isEmpty);
    },
  );
}