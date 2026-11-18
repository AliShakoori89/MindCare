import 'package:mind_care/Core/Sync/Domain/Repositories/conflict_repository.dart';

class KeepLocalConflict {
  final ConflictRepository _repository;

  KeepLocalConflict(this._repository);

  Future<void> call({required String outboxId, required String userId}) {
    return _repository.keepLocal(outboxId: outboxId, userId: userId);
  }
}
