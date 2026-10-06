import 'package:drift/drift.dart';
import '../Tables/users.dart';
import '../app_database.dart';
part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<User?> getUserById(String id) {
    return (select(users)..where((user) => user.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  Future<bool> updateUser(UsersCompanion user) {
    return update(users).replace(user);
  }

  Future<int> deleteUser(String id) {
    return (delete(users)..where((user) => user.id.equals(id))).go();
  }
}