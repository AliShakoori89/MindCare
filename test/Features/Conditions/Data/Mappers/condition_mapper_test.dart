import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart'
as domain;

void main() {
  final diagnosedAt = DateTime(2025, 1, 1);
  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 2);
  final deletedAt = DateTime(2026, 1, 3);

  group('ConditionMapper.toDomain', () {
    test('should map database condition to domain condition', () {
      final databaseCondition = db.Condition(
        id: 'condition-1',
        userId: 'user-1',
        name: 'Diabetes',
        status: 'active',
        diagnosedAt: diagnosedAt,
        diagnosedBy: 'Dr. Test',
        notes: 'Test condition',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

      final result = ConditionMapper.toDomain(databaseCondition);

      expect(result.id, 'condition-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Diabetes');
      expect(result.status, 'active');
      expect(result.diagnosedAt, diagnosedAt);
      expect(result.diagnosedBy, 'Dr. Test');
      expect(result.notes, 'Test condition');
      expect(result.createdAt, createdAt);
      expect(result.updatedAt, updatedAt);
      expect(result.deletedAt, deletedAt);
    });

    test('should preserve null deletedAt', () {
      final databaseCondition = db.Condition(
        id: 'condition-1',
        userId: 'user-1',
        name: 'Diabetes',
        status: 'active',
        diagnosedAt: diagnosedAt,
        diagnosedBy: 'Dr. Test',
        notes: 'Test condition',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );

      final result = ConditionMapper.toDomain(databaseCondition);

      expect(result.deletedAt, isNull);
    });
  });

  group('ConditionMapper.toCompanion', () {
    test('should map domain condition to database companion', () {
      final condition = domain.Condition(
        id: 'condition-1',
        userId: 'user-1',
        name: 'Diabetes',
        status: 'active',
        diagnosedAt: diagnosedAt,
        diagnosedBy: 'Dr. Test',
        notes: 'Test condition',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

      final result = ConditionMapper.toCompanion(condition);

      expect(result.id.value, 'condition-1');
      expect(result.userId.value, 'user-1');
      expect(result.name.value, 'Diabetes');
      expect(result.status.value, 'active');
      expect(result.diagnosedAt.value, diagnosedAt);
      expect(result.diagnosedBy.value, 'Dr. Test');
      expect(result.notes.value, 'Test condition');
      expect(result.createdAt.value, createdAt);
      expect(result.updatedAt.value, updatedAt);
      expect(result.deletedAt.value, deletedAt);
    });

    test('should preserve null deletedAt', () {
      final condition = domain.Condition(
        id: 'condition-1',
        userId: 'user-1',
        name: 'Diabetes',
        status: 'active',
        diagnosedAt: diagnosedAt,
        diagnosedBy: 'Dr. Test',
        notes: 'Test condition',
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );

      final result = ConditionMapper.toCompanion(condition);

      expect(result.deletedAt.value, isNull);
    });
  });
}