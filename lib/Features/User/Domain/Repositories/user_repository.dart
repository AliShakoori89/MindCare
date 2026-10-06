import '../Entities/user.dart';

abstract interface class UserRepository {
  Future<void> createUser(User user);

  Future<User?> getUserById(String id);

  Future<List<User>> getAllUsers();

  Future<void> updateUser(User user);

  Future<void> deleteUser(String id);
}