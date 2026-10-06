import 'package:drift/drift.dart';
import 'conversations.dart';

class Messages extends Table {
  TextColumn get id => text()();

  TextColumn get conversationId => text().references(Conversations, #id)();

  TextColumn get role => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {conversationId, createdAt},
  ];
}