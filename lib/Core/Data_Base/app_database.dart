import 'package:drift/drift.dart';
import 'Dao/conditions_dao.dart';
import 'Dao/medications_dao.dart';
import 'Dao/patient_profiles_dao.dart';
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
    PatientProfilesDao,
    ConditionsDao,
    MedicationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? openDatabaseConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },

    // onUpgrade: (m, from, to) async {
    //   if (from < 2) {
    //     await m.addColumn(
    //       patientProfiles,
    //       patientProfiles.nationalId,
    //     );
    //   }
    // },

    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}