import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';

abstract interface class ConditionRepository {
  Future<void> createCondition(Condition condition);

  Future<Condition?> getConditionById(String id);

  Future<List<Condition>> getConditionsByUserId(String userId);

  Future<void> updateCondition(Condition condition);

  Future<void> deleteCondition(String id);
}