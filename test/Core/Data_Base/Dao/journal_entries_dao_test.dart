import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Data_Base/Dao/journal_entries_dao.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late JournalEntriesDao dao;

  const userId = 'user-1';

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = JournalEntriesDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  JournalEntriesCompanion createEntry({
    required String id,
    String content = 'Test journal entry',
    int? mood,
    String? tags,
    String entryUserId = userId,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();

    return JournalEntriesCompanion.insert(
      id: id,
      userId: entryUserId,
      content: content,
      mood: drift.Value(mood),
      tags: drift.Value(tags),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> createUser() async {
    await database.into(database.users).insert(
      UsersCompanion.insert(
        id: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  group('JournalEntriesDao', () {
    setUp(() async {
      await createUser();
    });

    test('inserts and retrieves a journal entry by ID', () async {
      await dao.insertJournalEntry(
        createEntry(
          id: 'entry-1',
          content: 'Today was good',
          mood: 4,
          tags: 'work,health',
        ),
      );

      final result = await dao.getJournalEntryById('entry-1');

      expect(result, isNotNull);
      expect(result!.content, 'Today was good');
      expect(result.mood, 4);
      expect(result.tags, 'work,health');
      expect(result.userId, userId);
    });

    test('returns null when journal entry does not exist', () async {
      final result = await dao.getJournalEntryById('missing');

      expect(result, isNull);
    });

    test('returns user journal entries ordered by createdAt descending',
            () async {
          final older = DateTime(2026, 1, 1);
          final newer = DateTime(2026, 1, 2);

          await dao.insertJournalEntry(
            createEntry(id: 'entry-old', createdAt: older),
          );
          await dao.insertJournalEntry(
            createEntry(id: 'entry-new', createdAt: newer),
          );

          final result = await dao.getJournalEntriesByUserId(userId);

          expect(result, hasLength(2));
          expect(result[0].id, 'entry-new');
          expect(result[1].id, 'entry-old');
        });

    test('updates an existing journal entry', () async {
      await dao.insertJournalEntry(
        createEntry(id: 'entry-1', content: 'Original'),
      );

      final existing = await dao.getJournalEntryById('entry-1');
      expect(existing, isNotNull);

      final updated = existing!.copyWith(
        content: 'Updated content',
        updatedAt: DateTime.now(),
      );

      final success = await dao.updateJournalEntry(
        JournalEntriesCompanion(
          id: drift.Value(updated.id),
          userId: drift.Value(updated.userId),
          content: drift.Value(updated.content),
          mood: drift.Value(updated.mood),
          tags: drift.Value(updated.tags),
          createdAt: drift.Value(updated.createdAt),
          updatedAt: drift.Value(updated.updatedAt),
          deletedAt: drift.Value(updated.deletedAt),
        ),
      );

      expect(success, isTrue);

      final result = await dao.getJournalEntryById('entry-1');
      expect(result!.content, 'Updated content');
    });

    test('soft deletes an entry and hides it from reads', () async {
      await dao.insertJournalEntry(createEntry(id: 'entry-1'));

      await dao.deleteJournalEntry('entry-1');

      final byId = await dao.getJournalEntryById('entry-1');
      final byUser = await dao.getJournalEntriesByUserId(userId);

      expect(byId, isNull);
      expect(byUser, isEmpty);

      final rawEntry = await (database.select(database.journalEntries)
        ..where((table) => table.id.equals('entry-1')))
          .getSingle();

      expect(rawEntry.deletedAt, isNotNull);
    });

    test('does not return another user journal entries', () async {
      await database.into(database.users).insert(
        UsersCompanion.insert(
          id: 'user-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await dao.insertJournalEntry(createEntry(id: 'entry-1'));
      await dao.insertJournalEntry(
        createEntry(
          id: 'entry-2',
          entryUserId: 'user-2',
        ),
      );

      final result = await dao.getJournalEntriesByUserId(userId);

      expect(result, hasLength(1));
      expect(result.single.id, 'entry-1');
    });

    test('does not return soft-deleted entries', () async {
      await dao.insertJournalEntry(createEntry(id: 'entry-1'));
      await dao.deleteJournalEntry('entry-1');

      final result = await dao.getJournalEntriesByUserId(userId);

      expect(result, isEmpty);
    });
  });
}