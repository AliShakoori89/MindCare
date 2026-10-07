import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/create_condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/delete_condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/get_condition_by_id.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/get_conditions_by_user_id.dart';
import 'package:mind_care/Features/Conditions/Domain/Use_Cases/update_condition.dart';
import 'package:mind_care/Features/Conditions/Presentation/Bloc/condition_bloc.dart';
import 'package:mind_care/Features/Conditions/Presentation/Bloc/condition_event.dart';
import 'package:mind_care/Features/Conditions/Presentation/Bloc/condition_state.dart';

class FakeConditionRepository implements ConditionRepository {
  final List<Condition> conditions = [];

  bool shouldThrow = false;

  @override
  Future<void> createCondition(Condition condition) async {
    if (shouldThrow) {
      throw Exception('Create condition failed');
    }

    conditions.add(condition);
  }

  @override
  Future<Condition?> getConditionById(String id) async {
    if (shouldThrow) {
      throw Exception('Get condition failed');
    }

    for (final condition in conditions) {
      if (condition.id == id && condition.deletedAt == null) {
        return condition;
      }
    }

    return null;
  }

  @override
  Future<List<Condition>> getConditionsByUserId(String userId) async {
    if (shouldThrow) {
      throw Exception('Get conditions failed');
    }

    return conditions
        .where(
          (condition) =>
      condition.userId == userId &&
          condition.deletedAt == null,
    )
        .toList();
  }

  @override
  Future<void> updateCondition(Condition condition) async {
    if (shouldThrow) {
      throw Exception('Update condition failed');
    }

    final index = conditions.indexWhere(
          (item) => item.id == condition.id,
    );

    if (index != -1) {
      conditions[index] = condition;
    }
  }

  @override
  Future<void> deleteCondition(String id) async {
    if (shouldThrow) {
      throw Exception('Delete condition failed');
    }

    final index = conditions.indexWhere(
          (condition) => condition.id == id,
    );

    if (index != -1) {
      conditions[index] = conditions[index].copyWith(
        deletedAt: DateTime(2026, 1, 2),
      );
    }
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
  late ConditionBloc bloc;

  setUp(() {
    repository = FakeConditionRepository();

    bloc = ConditionBloc(
      createCondition: CreateCondition(repository),
      getConditionById: GetConditionById(repository),
      getConditionsByUserId: GetConditionsByUserId(repository),
      updateCondition: UpdateCondition(repository),
      deleteCondition: DeleteCondition(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('ConditionBloc', () {
    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Created when condition is created',
      build: () => bloc,
      act: (bloc) => bloc.add(
        CreateConditionEvent(createTestCondition()),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionCreated>(),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Loaded when condition is found by id',
      build: () {
        repository.conditions.add(createTestCondition());
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetConditionByIdEvent('condition-1'),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionLoaded>().having(
              (state) => state.condition.id,
          'condition id',
          'condition-1',
        ),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Error when condition is not found by id',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const GetConditionByIdEvent('unknown-condition'),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionError>().having(
              (state) => state.message,
          'message',
          'Condition not found',
        ),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Loaded when conditions are found by user id',
      build: () {
        repository.conditions.add(createTestCondition());
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetConditionsByUserIdEvent('user-1'),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionsLoaded>().having(
              (state) => state.conditions.length,
          'conditions count',
          1,
        ),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Loaded with empty list when no conditions exist',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const GetConditionsByUserIdEvent('unknown-user'),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionsLoaded>().having(
              (state) => state.conditions,
          'conditions',
          isEmpty,
        ),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Updated when condition is updated',
      build: () {
        repository.conditions.add(createTestCondition());
        return bloc;
      },
      act: (bloc) {
        final updatedCondition = createTestCondition().copyWith(
          name: 'Updated Diabetes',
        );

        bloc.add(
          UpdateConditionEvent(updatedCondition),
        );
      },
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionUpdated>(),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Loading and Deleted when condition is deleted',
      build: () {
        repository.conditions.add(createTestCondition());
        return bloc;
      },
      act: (bloc) => bloc.add(
        const DeleteConditionEvent('condition-1'),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionDeleted>(),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Error when create fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) => bloc.add(
        CreateConditionEvent(createTestCondition()),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionError>().having(
              (state) => state.message,
          'message',
          'Exception: Create condition failed',
        ),
      ],
    );

    blocTest<ConditionBloc, ConditionState>(
      'emits Error when update fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateConditionEvent(createTestCondition()),
      ),
      expect: () => [
        isA<ConditionLoading>(),
        isA<ConditionError>().having(
              (state) => state.message,
          'message',
          'Exception: Update condition failed',
        ),
      ],
    );
  });
}