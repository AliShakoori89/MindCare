import 'package:drift/drift.dart';
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
  ],
  daos: [
    UsersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {},
  );
}