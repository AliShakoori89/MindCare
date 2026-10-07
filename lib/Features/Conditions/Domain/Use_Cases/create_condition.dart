import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class CreateCondition {
  final ConditionRepository _repository;

  CreateCondition(this._repository);

  Future<void> call(Condition condition) {
    return _repository.createCondition(condition);
  }
}