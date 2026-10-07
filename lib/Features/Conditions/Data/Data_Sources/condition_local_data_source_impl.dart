import 'package:mind_care/Core/Data_Base/Dao/conditions_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

import 'condition_local_data_source.dart';

class ConditionLocalDataSourceImpl
    implements ConditionLocalDataSource {
  final ConditionsDao _dao;

  ConditionLocalDataSourceImpl(this._dao);

  @override
  Future<void> insertCondition(ConditionsCompanion condition) {
    return _dao.insertCondition(condition);
  }

  @override
  Future<Condition?> getConditionById(String id) {
    return _dao.getConditionById(id);
  }

  @override
  Future<List<Condition>> getConditionsByUserId(String userId) {
    return _dao.getConditionsByUserId(userId);
  }

  @override
  Future<bool> updateCondition(
      ConditionsCompanion condition,
      ) {
    return _dao.updateCondition(condition);
  }

  @override
  Future<int> deleteCondition(String id) {
    return _dao.deleteCondition(id);
  }
}