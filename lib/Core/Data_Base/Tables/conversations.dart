import 'package:drift/drift.dart';

class Conversations extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get title => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId, updatedAt},
  ];
}