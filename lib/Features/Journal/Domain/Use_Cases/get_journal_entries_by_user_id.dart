import '../Entities/journal_entry.dart';
import '../Repositories/journal_repository.dart';

class GetJournalEntriesByUserId {
  final JournalRepository repository;

  GetJournalEntriesByUserId(this.repository);

  Future<List<JournalEntry>> call(String userId) {
    return repository.getJournalEntriesByUserId(userId);
  }
}