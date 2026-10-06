import 'package:mind_care/Core/Data_Base/app_database.dart'
as db;
import 'package:mind_care/Features/User/Domain/Entities/user.dart'
as domain;

extension UserModelMapper on db.User {
  domain.User toDomain() {
    return domain.User(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserEntityMapper on domain.User {
  db.UsersCompanion toCompanion() {
    return db.UsersCompanion.insert(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}