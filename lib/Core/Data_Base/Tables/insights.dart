import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class Insights extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

  TextColumn get type => text()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  TextColumn get severity => text()();

  TextColumn get source => text()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get expiresAt => dateTime().nullable()();

  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {userId, createdAt},
    {userId, type},
  ];
}