import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';

abstract class JournalEvent {}

class CreateJournalEntryEvent extends JournalEvent {
  final JournalEntry entry;

  CreateJournalEntryEvent(this.entry);
}

class LoadJournalEntryByIdEvent extends JournalEvent {
  final String id;

  LoadJournalEntryByIdEvent(this.id);
}

class LoadJournalEntriesByUserIdEvent extends JournalEvent {
  final String userId;

  LoadJournalEntriesByUserIdEvent(this.userId);
}

class UpdateJournalEntryEvent extends JournalEvent {
  final JournalEntry entry;

  UpdateJournalEntryEvent(this.entry);
}

class DeleteJournalEntryEvent extends JournalEvent {
  final String id;

  DeleteJournalEntryEvent(this.id);
}