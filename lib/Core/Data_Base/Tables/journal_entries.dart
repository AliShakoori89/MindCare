import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class JournalEntries extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

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