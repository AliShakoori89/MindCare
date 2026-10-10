import '../Entities/journal_entry.dart';
import '../Repositories/journal_repository.dart';

class UpdateJournalEntry {
  final JournalRepository repository;

  UpdateJournalEntry(this.repository);

  Future<void> call(JournalEntry entry) {
    return repository.updateJournalEntry(entry);
  }
}