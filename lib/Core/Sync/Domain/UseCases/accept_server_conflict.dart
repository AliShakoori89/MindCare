import 'package:mind_care/Core/Sync/Domain/Repositories/conflict_repository.dart';

class AcceptServerConflict {
  final ConflictRepository _repository;

  AcceptServerConflict(this._repository);

  Future<void> call({required String outboxId, required String userId}) {
    return _repository.acceptServer(outboxId: outboxId, userId: userId);
  }
}
