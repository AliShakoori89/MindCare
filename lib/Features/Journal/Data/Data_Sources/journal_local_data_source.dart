import 'package:mind_care/Core/Data_Base/Dao/journal_entries_dao.dart';
import '../../../../Core/Data_Base/app_database.dart';

abstract class JournalLocalDataSource {
  Future<void> createJournalEntry(JournalEntriesCompanion entry);

  Future<JournalEntry?> getJournalEntryById(String id);

  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      );

  Future<bool> updateJournalEntry(JournalEntriesCompanion entry);

  Future<void> deleteJournalEntry(String id);
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final JournalEntriesDao dao;

  JournalLocalDataSourceImpl(this.dao);

  @override
  Future<void> createJournalEntry(JournalEntriesCompanion entry) {
    return dao.insertJournalEntry(entry);
  }

  @override
  Future<JournalEntry?> getJournalEntryById(String id) {
    return dao.getJournalEntryById(id);
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      ) {
    return dao.getJournalEntriesByUserId(userId);
  }

  @override
  Future<bool> updateJournalEntry(JournalEntriesCompanion entry) {
    return dao.updateJournalEntry(entry);
  }

  @override
  Future<void> deleteJournalEntry(String id) {
    return dao.deleteJournalEntry(id);
  }
}