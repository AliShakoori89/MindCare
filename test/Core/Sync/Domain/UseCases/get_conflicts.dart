import 'package:mind_care/Core/Sync/Domain/Entities/conflict_entry.dart';
import 'package:mind_care/Core/Sync/Domain/Repositories/conflict_repository.dart';

class GetConflicts {
  final ConflictRepository _repository;

  GetConflicts(this._repository);

  Future<List<ConflictEntry>> call({required String userId}) {
    return _repository.getConflicts(userId: userId);
  }
}