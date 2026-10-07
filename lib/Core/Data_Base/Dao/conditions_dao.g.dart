// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_dao.dart';

// ignore_for_file: type=lint
mixin _$ConditionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $ConditionsTable get conditions => attachedDatabase.conditions;
  ConditionsDaoManager get managers => ConditionsDaoManager(this);
}

class ConditionsDaoManager {
  final _$ConditionsDaoMixin _db;
  ConditionsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$ConditionsTableTableManager get conditions =>
      $$ConditionsTableTableManager(_db.attachedDatabase, _db.conditions);
}
