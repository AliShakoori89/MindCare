import '../Entities/journal_entry.dart';

abstract class JournalRepository {
  Future<void> createJournalEntry(JournalEntry entry);

  Future<JournalEntry?> getJournalEntryById(String id);

  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      );

  Future<void> updateJournalEntry(JournalEntry entry);

  Future<void> deleteJournalEntry(String id);
}