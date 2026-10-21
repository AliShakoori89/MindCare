import 'package:drift/drift.dart';

class Outbox extends Table {
  TextColumn get id => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get operation => text()();

  TextColumn get payload => text()();

  TextColumn get status => text()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {entityType, entityId},
    {status, createdAt},
  ];
}