import 'package:drift/drift.dart';
import '../Tables/conditions.dart';
import '../app_database.dart';

part 'conditions_dao.g.dart';

@DriftAccessor(tables: [Conditions])
class ConditionsDao extends DatabaseAccessor<AppDatabase>
    with _$ConditionsDaoMixin {
  ConditionsDao(super.db);

  Future<void> insertCondition(ConditionsCompanion condition) {
    return into(conditions).insert(condition);
  }

  Future<Condition?> getConditionById(String id) {
    return (select(conditions)
      ..where((condition) =>
      condition.id.equals(id) &
      condition.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<Condition>> getConditionsByUserId(String userId) {
    return (select(conditions)
      ..where((condition) =>
      condition.userId.equals(userId) &
      condition.deletedAt.isNull()))
        .get();
  }

  Future<bool> updateCondition(ConditionsCompanion condition) {
    return update(conditions).replace(condition);
  }

  Future<int> deleteCondition(String id) {
    return (update(conditions)
      ..where((condition) =>
      condition.id.equals(id) &
      condition.deletedAt.isNull()))
        .write(
      ConditionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}