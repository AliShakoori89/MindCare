import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';
import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class GetConditionById {
  final ConditionRepository _repository;

  GetConditionById(this._repository);

  Future<Condition?> call(String id) {
    return _repository.getConditionById(id);
  }
}