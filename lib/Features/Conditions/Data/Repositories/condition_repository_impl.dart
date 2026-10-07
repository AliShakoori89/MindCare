import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_local_data_source.dart';
import 'package:mind_care/Features/Conditions/Data/Mappers/condition_mapper.dart';
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class ConditionRepositoryImpl implements ConditionRepository {
  final ConditionLocalDataSource _localDataSource;

  ConditionRepositoryImpl(this._localDataSource);

  @override
  Future<void> createCondition(Condition condition) {
    return _localDataSource.insertCondition(
      ConditionMapper.toCompanion(condition),
    );
  }

  @override
  Future<Condition?> getConditionById(String id) async {
    final condition = await _localDataSource.getConditionById(id);

    if (condition == null) {
      return null;
    }

    return ConditionMapper.toDomain(condition);
  }

  @override
  Future<List<Condition>> getConditionsByUserId(
      String userId,
      ) async {
    final conditions =
    await _localDataSource.getConditionsByUserId(userId);

    return conditions
        .map(ConditionMapper.toDomain)
        .toList();
  }

  @override
  Future<void> updateCondition(Condition condition) {
    return _localDataSource.updateCondition(
      ConditionMapper.toCompanion(condition),
    );
  }

  @override
  Future<void> deleteCondition(String id) async {
    await _localDataSource.deleteCondition(id);
  }
}