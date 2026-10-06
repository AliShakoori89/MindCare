import 'package:mind_care/Features/User/Data/Mappers/user_mapper.dart';
import 'package:mind_care/Features/User/Domain/Entities/user.dart';
import 'package:mind_care/Features/User/Domain/Repositories/user_repository.dart';
import '../Data_Sources/user_local_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource _localDataSource;

  UserRepositoryImpl(this._localDataSource);

  @override
  Future<void> createUser(User user) {
    return _localDataSource.insertUser(
      user.toCompanion(),
    );
  }

  @override
  Future<User?> getUserById(String id) async {
    final user = await _localDataSource.getUserById(id);

    return user?.toDomain();
  }

  @override
  Future<List<User>> getAllUsers() async {
    final users = await _localDataSource.getAllUsers();

    return users.map((user) => user.toDomain()).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await _localDataSource.updateUser(
      user.toCompanion(),
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await _localDataSource.deleteUser(id);
  }
}