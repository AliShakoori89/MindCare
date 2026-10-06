import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class MedicalDocuments extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

  TextColumn get type => text()();

  TextColumn get title => text()();

  TextColumn get fileReference => text()();

  DateTimeColumn get documentDate => dateTime().nullable()();

  TextColumn get metadata => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId, documentDate},
  ];
}