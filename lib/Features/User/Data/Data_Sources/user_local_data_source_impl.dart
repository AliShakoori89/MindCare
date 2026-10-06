import 'package:mind_care/Core/Data_Base/Dao/users_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final UsersDao _usersDao;

  UserLocalDataSourceImpl(this._usersDao);

  @override
  Future<void> insertUser(UsersCompanion user) {
    return _usersDao.insertUser(user);
  }

  @override
  Future<User?> getUserById(String id) {
    return _usersDao.getUserById(id);
  }

  @override
  Future<List<User>> getAllUsers() {
    return _usersDao.getAllUsers();
  }

  @override
  Future<bool> updateUser(UsersCompanion user) {
    return _usersDao.updateUser(user);
  }

  @override
  Future<int> deleteUser(String id) {
    return _usersDao.deleteUser(id);
  }
}