// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_profiles_dao.dart';

// ignore_for_file: type=lint
mixin _$PatientProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PatientProfilesTable get patientProfiles => attachedDatabase.patientProfiles;
  PatientProfilesDaoManager get managers => PatientProfilesDaoManager(this);
}

class PatientProfilesDaoManager {
  final _$PatientProfilesDaoMixin _db;
  PatientProfilesDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PatientProfilesTableTableManager get patientProfiles =>
      $$PatientProfilesTableTableManager(
        _db.attachedDatabase,
        _db.patientProfiles,
      );
}
