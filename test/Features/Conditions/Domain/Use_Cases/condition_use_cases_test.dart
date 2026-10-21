import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/create_condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/delete_condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/get_condition_by_id.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/get_conditions_by_user_id.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/update_condition.dart';

class FakeConditionRepository implements ConditionRepository {
  Condition? createdCondition;
  Condition? updatedCondition;
  String? deletedId;

  List<Condition> conditions = [];

  @override
  Future<void> createCondition(Condition condition) async {
    createdCondition = condition;
  }

  @override
  Future<void> deleteCondition(String id) async {
    deletedId = id;
  }

  @override
  Future<Condition?> getConditionById(String id) async {
    return conditions.where((condition) => condition.id == id).firstOrNull;
  }

  @override
  Future<List<Condition>> getConditionsByUserId(String userId) async {
    return conditions
        .where((condition) => condition.userId == userId)
        .toList();
  }

  @override
  Future<void> updateCondition(Condition condition) async {
    updatedCondition = condition;
  }
}

Condition createTestCondition() {
  return Condition(
    id: 'condition-1',
    userId: 'user-1',
    name: 'Diabetes',
    status: 'active',
    diagnosedAt: DateTime(2025, 1, 1),
    diagnosedBy: 'Dr. Test',
    notes: 'Test condition',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late FakeConditionRepository repository;

  setUp(() {
    repository = FakeConditionRepository();
  });

  group('CreateCondition', () {
    test('should delegate creation to repository', () async {
      final useCase = CreateCondition(repository);
      final condition = createTestCondition();

      await useCase(condition);

      expect(repository.createdCondition, condition);
    });
  });

  group('DeleteCondition', () {
    test('should delegate deletion to repository', () async {
      final useCase = DeleteCondition(repository);

      await useCase('condition-1');

      expect(repository.deletedId, 'condition-1');
    });
  });

  group('GetConditionById', () {
    test('should return condition from repository', () async {
      final condition = createTestCondition();
      repository.conditions = [condition];

      final useCase = GetConditionById(repository);

      final result = await useCase('condition-1');

      expect(result, condition);
    });
  });

  group('GetConditionsByUserId', () {
    test('should return conditions from repository', () async {
      final condition = createTestCondition();
      repository.conditions = [condition];

      final useCase = GetConditionsByUserId(repository);

      final result = await useCase('user-1');

      expect(result, [condition]);
    });
  });

  group('UpdateCondition', () {
    test('should delegate update to repository', () async {
      final useCase = UpdateCondition(repository);
      final condition = createTestCondition();

      await useCase(condition);

      expect(repository.updatedCondition, condition);
    });
  });
}