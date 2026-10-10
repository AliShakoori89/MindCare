import 'package:drift/drift.dart' as drift;
import '../../../../Core/Data_Base/app_database.dart' as db;
import '../../Domain/Entities/journal_entry.dart';

class JournalEntryMapper {
  static JournalEntry toDomain(db.JournalEntry entry) {
    return JournalEntry(
      id: entry.id,
      userId: entry.userId,
      content: entry.content,
      mood: entry.mood,
      tags: entry.tags,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      deletedAt: entry.deletedAt,
    );
  }

  static db.JournalEntriesCompanion toCompanion(
      JournalEntry entry,
      ) {
    return db.JournalEntriesCompanion(
      id: drift.Value(entry.id),
      userId: drift.Value(entry.userId),
      content: drift.Value(entry.content),
      mood: drift.Value(entry.mood),
      tags: drift.Value(entry.tags),
      createdAt: drift.Value(entry.createdAt),
      updatedAt: drift.Value(entry.updatedAt),
      deletedAt: drift.Value(entry.deletedAt),
    );
  }
}