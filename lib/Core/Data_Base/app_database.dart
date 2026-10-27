import 'package:drift/drift.dart';

import 'Dao/conditions_dao.dart';
import 'Dao/conversations_dao.dart';
import 'Dao/daily_check_ins_dao.dart';
import 'Dao/medications_dao.dart';
import 'Dao/messages_dao.dart';
import 'Dao/outbox_dao.dart';
import 'Dao/patient_profiles_dao.dart';
import 'Dao/sync_cursor_dao.dart';
import 'Dao/users_dao.dart';
import 'Tables/conversations.dart';
import 'Tables/daily_check_ins.dart';
import 'Tables/insights.dart';
import 'Tables/journal_entries.dart';
import 'Tables/medical_documents.dart';
import 'Tables/medications.dart';
import 'Tables/conditions.dart';
import 'Tables/messages.dart';
import 'Tables/patient_profiles.dart';
import 'Tables/timeline_events.dart';
import 'Tables/users.dart';
import 'database_connection.dart';
import 'Tables/outbox.dart';
import 'Tables/sync_cursors.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    PatientProfiles,
    Conditions,
    Medications,
    DailyCheckIns,
    JournalEntries,
    MedicalDocuments,
    TimelineEvents,
    Insights,
    Conversations,
    Messages,
    Outbox,
    SyncCursors,
  ],
  daos: [
    UsersDao,
    PatientProfilesDao,
    ConditionsDao,
    MedicationsDao,
    ConversationsDao,
    MessagesDao,
    DailyCheckInsDao,
    OutboxDao,
    SyncCursorDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openDatabaseConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },

    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(outbox);
        await m.createTable(syncCursors);
      }

      if (from < 3) {
        await customStatement('''
    CREATE TABLE sync_cursors_new (
      id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      cursor TEXT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

        await customStatement('''
    INSERT INTO sync_cursors_new (
      id,
      user_id,
      cursor,
      updated_at
    )
    SELECT
      id,
      user_id,
      cursor,
      updated_at
    FROM sync_cursors AS source
    WHERE NOT EXISTS (
      SELECT 1
      FROM sync_cursors AS other
      WHERE other.user_id = source.user_id
        AND (
          other.updated_at > source.updated_at
          OR (
            other.updated_at = source.updated_at
            AND other.id > source.id
          )
        )
    )
  ''');

        await customStatement('DROP TABLE sync_cursors');

        await customStatement(
          'ALTER TABLE sync_cursors_new RENAME TO sync_cursors',
        );
      }

      if (from < 4) {
        await m.addColumn(outbox, outbox.userId);
      }
    },

    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
