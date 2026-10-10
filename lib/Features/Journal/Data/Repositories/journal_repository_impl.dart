import '../../Domain/Entities/journal_entry.dart';
import '../../Domain/Repositories/journal_repository.dart';
import '../Data_Sources/journal_local_data_source.dart';
import '../Mappers/journal_entry_mapper.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  JournalRepositoryImpl(this.localDataSource);

  @override
  Future<void> createJournalEntry(JournalEntry entry) {
    return localDataSource.createJournalEntry(
      JournalEntryMapper.toCompanion(entry),
    );
  }

  @override
  Future<JournalEntry?> getJournalEntryById(String id) async {
    final entry = await localDataSource.getJournalEntryById(id);

    if (entry == null) return null;

    return JournalEntryMapper.toDomain(entry);
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesByUserId(
      String userId,
      ) async {
    final entries =
    await localDataSource.getJournalEntriesByUserId(userId);

    return entries.map(JournalEntryMapper.toDomain).toList();
  }

  @override
  Future<void> updateJournalEntry(JournalEntry entry) async {
    await localDataSource.updateJournalEntry(
      JournalEntryMapper.toCompanion(entry),
    );
  }

  @override
  Future<void> deleteJournalEntry(String id) {
    return localDataSource.deleteJournalEntry(id);
  }
}