import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Domain/Entities/conflict_entry.dart';
import 'package:mind_care/Core/Sync/Domain/Repositories/conflict_repository.dart';
import 'package:mind_care/Core/Sync/Domain/UseCases/accept_server_conflict.dart';
import 'package:mind_care/Core/Sync/Domain/UseCases/keep_local_conflict.dart';

import 'get_conflicts.dart';

void main() {
  late FakeConflictRepository repository;

  setUp(() {
    repository = FakeConflictRepository();
  });

  group('GetConflicts', () {
    test('should forward userId to repository', () async {
      final useCase = GetConflicts(repository);

      final result = await useCase(userId: 'user-1');

      expect(result, isEmpty);
      expect(repository.requestedUserId, 'user-1');
    });
  });

  group('KeepLocalConflict', () {
    test('should forward outboxId and userId to repository', () async {
      final useCase = KeepLocalConflict(repository);

      await useCase(outboxId: 'outbox-1', userId: 'user-1');

      expect(repository.keptOutboxId, 'outbox-1');
      expect(repository.keptUserId, 'user-1');
    });
  });

  group('AcceptServerConflict', () {
    test('should forward outboxId and userId to repository', () async {
      final useCase = AcceptServerConflict(repository);

      await useCase(outboxId: 'outbox-2', userId: 'user-2');

      expect(repository.acceptedOutboxId, 'outbox-2');
      expect(repository.acceptedUserId, 'user-2');
    });
  });
}

class FakeConflictRepository implements ConflictRepository {
  String? keptOutboxId;
  String? keptUserId;

  String? acceptedOutboxId;
  String? acceptedUserId;
  String? requestedUserId;

  @override
  Future<List<ConflictEntry>> getConflicts({required String userId}) async {
    requestedUserId = userId;
    return [];
  }

  @override
  Future<void> keepLocal({
    required String outboxId,
    required String userId,
  }) async {
    keptOutboxId = outboxId;
    keptUserId = userId;
  }

  @override
  Future<void> acceptServer({
    required String outboxId,
    required String userId,
  }) async {
    acceptedOutboxId = outboxId;
    acceptedUserId = userId;
  }
}
