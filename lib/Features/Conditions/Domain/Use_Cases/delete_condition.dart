import 'package:mind_care/Features/Conditions/Domain/Repositories/condition_repository.dart';

class DeleteCondition {
  final ConditionRepository _repository;

  DeleteCondition(this._repository);

  Future<void> call(String id) {
    return _repository.deleteCondition(id);
  }
}