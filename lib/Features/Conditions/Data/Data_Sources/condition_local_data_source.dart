import 'package:mind_care/Core/Data_Base/app_database.dart';

abstract interface class ConditionLocalDataSource {
  Future<void> insertCondition(ConditionsCompanion condition);

  Future<Condition?> getConditionById(String id);

  Future<List<Condition>> getConditionsByUserId(String userId);

  Future<bool> updateCondition(ConditionsCompanion condition);

  Future<int> deleteCondition(String id);
}