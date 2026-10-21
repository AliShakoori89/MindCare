
import 'package:drift/drift.dart';

class SyncCursors extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get cursor => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE (user_id)',
  ];
}
