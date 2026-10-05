import 'package:drift/drift.dart';

class JournalEntries extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get content => text()();

  IntColumn get mood => integer().nullable()();

  TextColumn get tags => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId, createdAt},
  ];
}