import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class UpdateCondition {
  final ConditionRepository _repository;

  UpdateCondition(this._repository);

  Future<void> call(Condition condition) {
    return _repository.updateCondition(condition);
  }
}