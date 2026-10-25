import 'package:drift/drift.dart';
import '../Tables/outbox.dart';
import '../app_database.dart';
part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<AppDatabase>
    with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<void> insertOutbox(OutboxCompanion entry) {
    return into(outbox).insert(entry);
  }

  Future<List<OutboxData>> getPendingEntries() {
    return (select(outbox)
      ..where((entry) => entry.status.equals('pending'))
      ..orderBy([
            (entry) => OrderingTerm.asc(entry.createdAt),
      ]))
        .get();
  }

  Future<OutboxData?> getById(String id) {
    return (select(outbox)
      ..where((entry) => entry.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateOutbox(OutboxCompanion entry) {
    return update(outbox).replace(entry);
  }

  Future<int> markAsFailed({
    required String id,
    required int attempts,
    required String error,
  }) {
    return (update(outbox)..where((entry) => entry.id.equals(id))).write(
      OutboxCompanion(
        attempts: Value(attempts),
        lastError: Value(error),
        status: const Value('pending'),
      ),
    );
  }

  Future<int> deleteById(String id) {
    return (delete(outbox)
      ..where((entry) => entry.id.equals(id)))
        .go();
  }

  Future<int> deleteByEntity({
    required String entityType,
    required String entityId,
  }) {
    return (delete(outbox)
      ..where(
            (entry) =>
        entry.entityType.equals(entityType) &
        entry.entityId.equals(entityId),
      ))
        .go();
  }
}