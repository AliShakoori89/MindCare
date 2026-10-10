import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Core/Data_Base/Tables/journal_entries.dart';

part 'journal_entries_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$JournalEntriesDaoMixin {
  JournalEntriesDao(super.db);

  // Create
  Future<void> insertJournalEntry(
      JournalEntriesCompanion entry,
      ) async {
    await into(journalEntries).insert(entry);
  }

  // Read by ID
  Future<JournalEntry?> getJournalEntryById(String id) {
    return (select(journalEntries)
      ..where(
            (table) =>
        table.id.equals(id) & table.deletedAt.isNull(),
      ))
        .getSingleOrNull();
  }

  // Read all active journal entries for a user
  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      ) {
    return (select(journalEntries)
      ..where(
            (table) =>
        table.userId.equals(userId) &
        table.deletedAt.isNull(),
      )
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]))
        .get();
  }

  // Update
  Future<bool> updateJournalEntry(
      JournalEntriesCompanion entry,
      ) {
    return update(journalEntries).replace(entry);
  }

  // Soft delete
  Future<void> deleteJournalEntry(String id) async {
    final now = DateTime.now();

    await (update(journalEntries)
      ..where(
            (table) =>
        table.id.equals(id) & table.deletedAt.isNull(),
      ))
        .write(
      JournalEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}