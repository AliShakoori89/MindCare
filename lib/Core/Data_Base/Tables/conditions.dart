import 'package:drift/drift.dart';

class Conditions extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get name => text()();

  TextColumn get status => text()();

  DateTimeColumn get diagnosedAt => dateTime().nullable()();

  TextColumn get diagnosedBy => text().nullable()();

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