import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Repositories/journal_repository.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/create_journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/delete_journal_entry.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/get_journal_entries_by_user_id.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/get_journal_entry_by_id.dart';
import 'package:mind_care/Features/Journal/Domain/Use_Cases/update_journal_entry.dart';

class FakeJournalRepository implements JournalRepository {
  final Map<String, JournalEntry> entries = {};

  @override
  Future<void> createJournalEntry(JournalEntry entry) async {
    entries[entry.id] = entry;
  }

  @override
  Future<JournalEntry?> getJournalEntryById(String id) async {
    return entries[id];
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      ) async {
    return entries.values
        .where((entry) => entry.userId == userId)
        .toList();
  }

  @override
  Future<void> updateJournalEntry(JournalEntry entry) async {
    if (entries.containsKey(entry.id)) {
      entries[entry.id] = entry;
    }
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    entries.remove(id);
  }
}

void main() {
  late FakeJournalRepository repository;
  late JournalEntry testEntry;

  setUp(() {
    repository = FakeJournalRepository();

    testEntry = JournalEntry(
      id: 'entry-1',
      userId: 'user-1',
      content: 'Today was a good day',
      mood: 4,
      tags: 'health,personal',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  group('Journal UseCases', () {
    test('CreateJournalEntry saves an entry', () async {
      final useCase = CreateJournalEntry(repository);

      await useCase(testEntry);

      expect(repository.entries['entry-1'], testEntry);
    });

    test('GetJournalEntryById returns the matching entry', () async {
      repository.entries['entry-1'] = testEntry;
      final useCase = GetJournalEntryById(repository);

      final result = await useCase('entry-1');

      expect(result, testEntry);
    });

    test('GetJournalEntryById returns null when missing', () async {
      final useCase = GetJournalEntryById(repository);

      final result = await useCase('missing');

      expect(result, isNull);
    });

    test('GetJournalEntriesByUserId returns only that user entries',
            () async {
          repository.entries['entry-1'] = testEntry;
          repository.entries['entry-2'] = JournalEntry(
            id: 'entry-2',
            userId: 'user-2',
            content: 'Another user entry',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
          );

          final useCase = GetJournalEntriesByUserId(repository);

          final result = await useCase('user-1');

          expect(result, hasLength(1));
          expect(result.single.id, 'entry-1');
        });

    test('UpdateJournalEntry updates an existing entry', () async {
      repository.entries['entry-1'] = testEntry;
      final useCase = UpdateJournalEntry(repository);
      final updated = testEntry.copyWith(
        content: 'Updated content',
        mood: 5,
      );

      await useCase(updated);

      expect(repository.entries['entry-1']!.content, 'Updated content');
      expect(repository.entries['entry-1']!.mood, 5);
    });

    test('DeleteJournalEntry removes an entry', () async {
      repository.entries['entry-1'] = testEntry;
      final useCase = DeleteJournalEntry(repository);

      await useCase('entry-1');

      expect(repository.entries, isEmpty);
    });
  });
}