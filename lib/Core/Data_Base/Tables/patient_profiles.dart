import 'package:drift/drift.dart';

class PatientProfiles extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get firstName => text()();

  TextColumn get lastName => text()();

  DateTimeColumn get birthDate => dateTime().nullable()();

  TextColumn get gender => text()();

  TextColumn get preferredLanguage => text()();

  TextColumn get emergencyContactName => text().nullable()();

  TextColumn get emergencyContactRelationship => text().nullable()();

  TextColumn get emergencyContactPhone => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId},
  ];
}