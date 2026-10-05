import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}