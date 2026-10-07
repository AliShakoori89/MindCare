import 'package:drift/drift.dart';
import '../Tables/patient_profiles.dart';
import '../app_database.dart';
part 'patient_profiles_dao.g.dart';

@DriftAccessor(tables: [PatientProfiles])
class PatientProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$PatientProfilesDaoMixin {
  PatientProfilesDao(super.db);

  Future<void> insertProfile(PatientProfilesCompanion profile) {
    return into(patientProfiles).insert(profile);
  }

  Future<PatientProfile?> getProfileById(String id) {
    return (select(patientProfiles)
      ..where((profile) => profile.id.equals(id)))
        .getSingleOrNull();
  }

  Future<PatientProfile?> getProfileByUserId(String userId) {
    return (select(patientProfiles)
      ..where((profile) => profile.userId.equals(userId)))
        .getSingleOrNull();
  }

  Stream<PatientProfile?> watchProfileByUserId(String userId) {
    return (select(patientProfiles)
      ..where((profile) => profile.userId.equals(userId)))
        .watchSingleOrNull();
  }

  Future<bool> updateProfile(PatientProfilesCompanion profile) {
    return update(patientProfiles).replace(profile);
  }

  Future<int> deleteProfile(String id) {
    return (delete(patientProfiles)
      ..where((profile) => profile.id.equals(id)))
        .go();
  }
}