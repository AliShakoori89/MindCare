import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class GetConditionsByUserId {
  final ConditionRepository _repository;

  GetConditionsByUserId(this._repository);

  Future<List<Condition>> call(String userId) {
    return _repository.getConditionsByUserId(userId);
  }
}