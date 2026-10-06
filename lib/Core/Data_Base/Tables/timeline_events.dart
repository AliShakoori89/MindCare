import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class TimelineEvents extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

  TextColumn get type => text()();

  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  TextColumn get referenceId => text().nullable()();

  TextColumn get metadata => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId, occurredAt},
  ];
}