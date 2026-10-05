import 'package:drift/drift.dart';
import 'Tables/conversations.dart';
import 'Tables/daily_check_ins.dart';
import 'Tables/insights.dart';
import 'Tables/journal_entries.dart';
import 'Tables/medical_documents.dart';
import 'Tables/medications.dart';
import 'Tables/conditions.dart';
import 'Tables/patient_profiles.dart';
import 'Tables/timeline_events.dart';
import 'Tables/users.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    throw UnimplementedError();
  }
}