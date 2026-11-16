
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

  // Returns only pending entries that are eligible for synchronization.
  Future<List<OutboxData>> getPendingEntries({
    required String userId,
  }) {
    return (select(outbox)
      ..where(
            (entry) =>
        entry.status.equals('pending') &
        entry.userId.equals(userId),
      )
      ..orderBy([
            (entry) => OrderingTerm.asc(entry.createdAt),
      ]))
        .get();
  }

  // Returns an existing pending or conflicted operation for an entity.
  Future<OutboxData?> getOperationForEntity({
    required String userId,
    required String entityType,
    required String entityId,
  }) {
    return (select(outbox)
      ..where(
            (entry) =>
        entry.userId.equals(userId) &
        entry.entityType.equals(entityType) &
        entry.entityId.equals(entityId) &
        entry.status.isIn(['pending', 'conflict']),
      )
      ..orderBy([
            (entry) => OrderingTerm.asc(entry.createdAt),
      ])
      ..limit(1))
        .getSingleOrNull();
  }

  // Pull must not overwrite entities with pending or conflicted local changes.
  Future<bool> hasPendingOrConflict({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    final entry = await (select(outbox)
      ..where(
            (item) =>
        item.userId.equals(userId) &
        item.entityType.equals(entityType) &
        item.entityId.equals(entityId) &
        item.status.isIn(['pending', 'conflict']),
      )
      ..limit(1))
        .getSingleOrNull();

    return entry != null;
  }

  // Kept for existing callers and tests.
  Future<bool> hasPendingOperation({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    final entry = await (select(outbox)
      ..where(
            (item) =>
        item.userId.equals(userId) &
        item.entityType.equals(entityType) &
        item.entityId.equals(entityId) &
        item.status.equals('pending'),
      )
      ..limit(1))
        .getSingleOrNull();

    return entry != null;
  }

  Future<OutboxData?> getById(String id) {
    return (select(outbox)
      ..where((entry) => entry.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateOutbox(OutboxCompanion entry) {
    return update(outbox).replace(entry);
  }

  // Updates only the payload. The original baseVersion and conflict data
  // remain unchanged.
  Future<int> updatePayload({
    required String id,
    required String payload,
  }) {
    return (update(outbox)..where((entry) => entry.id.equals(id))).write(
      OutboxCompanion(
        payload: Value(payload),
      ),
    );
  }

  // A conflict is not a transient failure. Do not increment attempts.
  Future<int> markAsConflict({
    required String id,
    required String conflictPayload,
    required String error,
  }) {
    return (update(outbox)..where((entry) => entry.id.equals(id))).write(
      OutboxCompanion(
        status: const Value('conflict'),
        conflictPayload: Value(conflictPayload),
        lastError: Value(error),
      ),
    );
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
    return (delete(outbox)..where((entry) => entry.id.equals(id))).go();
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
