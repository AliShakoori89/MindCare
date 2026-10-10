import 'package:mind_care/Features/Journal/Domain/Entities/journal_entry.dart';

abstract class JournalState {}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalOperationSuccess extends JournalState {
  final String message;

  JournalOperationSuccess(this.message);
}

class JournalEntryLoaded extends JournalState {
  final JournalEntry entry;

  JournalEntryLoaded(this.entry);
}

class JournalEntriesLoaded extends JournalState {
  final List<JournalEntry> entries;

  JournalEntriesLoaded(this.entries);
}

class JournalEntryNotFound extends JournalState {}

class JournalError extends JournalState {
  final String message;

  JournalError(this.message);
}