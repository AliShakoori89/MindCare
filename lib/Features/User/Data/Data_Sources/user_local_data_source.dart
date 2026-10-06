import 'package:mind_care/Core/Data_Base/app_database.dart';

abstract interface class UserLocalDataSource {
  Future<void> insertUser(UsersCompanion user);

  Future<User?> getUserById(String id);

  Future<List<User>> getAllUsers();

  Future<bool> updateUser(UsersCompanion user);

  Future<int> deleteUser(String id);
}