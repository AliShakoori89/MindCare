import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/Dao/journal_entries_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Journal/Data/Data_Sources/journal_local_data_source.dart';
import 'package:mind_care/Features/Journal/Data/Repositories/journal_repository_impl.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';

void main() {
  late db.AppDatabase database;
  late JournalRepositoryImpl repository;
  late JournalEntriesDao dao;

  const userId = 'user-1';

  setUp(() async {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    dao = JournalEntriesDao(database);

    repository = JournalRepositoryImpl(
      JournalLocalDataSourceImpl(dao),
    );

    await database.into(database.users).insert(
      db.UsersCompanion.insert(
        id: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  JournalEntry createEntry({
    String id = 'entry-1',
    String content = 'My journal entry',
    int? mood = 4,
    String? tags = 'health,work',
    DateTime? createdAt,
  }) {
    final now = DateTime.now();

    return JournalEntry(
      id: id,
      userId: userId,
      content: content,
      mood: mood,
      tags: tags,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  group('JournalRepositoryImpl', () {
    test('creates and retrieves a journal entry', () async {
      final entry = createEntry();

      await repository.createJournalEntry(entry);

      final result = await repository.getJournalEntryById(entry.id);

      expect(result, isNotNull);
      expect(result!.id, entry.id);
      expect(result.content, entry.content);
      expect(result.mood, entry.mood);
      expect(result.tags, entry.tags);
    });

    test('returns null for a missing entry', () async {
      final result = await repository.getJournalEntryById('missing');

      expect(result, isNull);
    });

    test('gets journal entries for a user', () async {
      await repository.createJournalEntry(
        createEntry(id: 'entry-1'),
      );
      await repository.createJournalEntry(
        createEntry(id: 'entry-2', content: 'Second entry'),
      );

      final result = await repository.getJournalEntriesByUserId(userId);

      expect(result, hasLength(2));
      expect(result.map((entry) => entry.id),
          containsAll(['entry-1', 'entry-2']));
    });

    test('updates a journal entry', () async {
      await repository.createJournalEntry(createEntry());

      final existing =
      await repository.getJournalEntryById('entry-1');

      final updated = existing!.copyWith(
        content: 'Updated content',
        mood: 5,
        tags: 'personal',
        updatedAt: DateTime.now(),
      );

      await repository.updateJournalEntry(updated);

      final result =
      await repository.getJournalEntryById('entry-1');

      expect(result!.content, 'Updated content');
      expect(result.mood, 5);
      expect(result.tags, 'personal');
    });

    test('soft deletes a journal entry', () async {
      await repository.createJournalEntry(createEntry());

      await repository.deleteJournalEntry('entry-1');

      final result =
      await repository.getJournalEntryById('entry-1');
      final entries =
      await repository.getJournalEntriesByUserId(userId);

      expect(result, isNull);
      expect(entries, isEmpty);
    });

    test('preserves the createdAt timestamp when updating', () async {
      final createdAt = DateTime(2026, 1, 1, 10);
      await repository.createJournalEntry(
        createEntry(createdAt: createdAt),
      );

      final existing =
      await repository.getJournalEntryById('entry-1');

      await repository.updateJournalEntry(
        existing!.copyWith(
          content: 'Edited entry',
          updatedAt: DateTime.now(),
        ),
      );

      final result =
      await repository.getJournalEntryById('entry-1');

      expect(result!.createdAt, createdAt);
    });
  });
}