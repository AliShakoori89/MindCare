// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_check_ins_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyCheckInsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $DailyCheckInsTable get dailyCheckIns => attachedDatabase.dailyCheckIns;
  DailyCheckInsDaoManager get managers => DailyCheckInsDaoManager(this);
}

class DailyCheckInsDaoManager {
  final _$DailyCheckInsDaoMixin _db;
  DailyCheckInsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$DailyCheckInsTableTableManager get dailyCheckIns =>
      $$DailyCheckInsTableTableManager(_db.attachedDatabase, _db.dailyCheckIns);
}
