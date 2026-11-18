import 'package:mind_care/Core/Sync/Domain/Entities/conflict_entry.dart';

abstract interface class ConflictRepository {
  /// Returns unresolved conflicts belonging to the requested user.
  Future<List<ConflictEntry>> getConflicts({required String userId});

  /// Keeps local changes and rebases the operation
  /// on the latest server version.
  Future<void> keepLocal({required String outboxId, required String userId});

  /// Replaces local data with the latest server snapshot
  /// and removes the resolved outbox entry.
  Future<void> acceptServer({required String outboxId, required String userId});
}
