import '../Entities/journal_entry.dart';
import '../Repositories/journal_repository.dart';

class GetJournalEntryById {
  final JournalRepository repository;

  GetJournalEntryById(this.repository);

  Future<JournalEntry?> call(String id) {
    return repository.getJournalEntryById(id);
  }
}