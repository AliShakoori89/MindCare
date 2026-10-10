import '../Entities/journal_entry.dart';
import '../Repositories/journal_repository.dart';

class CreateJournalEntry {
  final JournalRepository repository;

  CreateJournalEntry(this.repository);

  Future<void> call(JournalEntry entry) {
    return repository.createJournalEntry(entry);
  }
}