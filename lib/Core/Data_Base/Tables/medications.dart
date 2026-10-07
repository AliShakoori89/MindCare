import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class Medications extends Table {
  TextColumn get id => text()();

  TextColumn get userId =>
      text().references(
        Users,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get name => text()();

  TextColumn get genericName => text().nullable()();

  TextColumn get dosage => text().nullable()();

  TextColumn get unit => text().nullable()();

  TextColumn get frequencyType => text()();

  TextColumn get frequencyValue => text().nullable()();

  TextColumn get route => text()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get endDate => dateTime().nullable()();

  TextColumn get status => text()();

  TextColumn get prescribedBy => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId},
  ];
}