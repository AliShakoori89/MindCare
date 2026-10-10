import '../Repositories/journal_repository.dart';

class DeleteJournalEntry {
  final JournalRepository repository;

  DeleteJournalEntry(this.repository);

  Future<void> call(String id) {
    return repository.deleteJournalEntry(id);
  }
}