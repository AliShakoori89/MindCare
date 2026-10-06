import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/Tables/users.dart';

class DailyCheckIns extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

  DateTimeColumn get date => dateTime()();

  IntColumn get mood => integer().nullable()();

  IntColumn get anxiety => integer().nullable()();

  IntColumn get energy => integer().nullable()();

  IntColumn get stress => integer().nullable()();

  IntColumn get sleepDurationMinutes => integer().nullable()();

  IntColumn get sleepQuality => integer().nullable()();

  TextColumn get activityLevel => text().nullable()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, date},
  ];

  List<Set<Column>> get indexes => [
    {userId},
  ];
}