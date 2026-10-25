import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart'as db;
import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart'as domain;
import 'package:mind_care/Features/Conditions/Data/Models/condition_model.dart';

class ConditionMapper {
  static domain.Condition toDomain(db.Condition condition) {
    return domain.Condition(
      id: condition.id,
      userId: condition.userId,
      name: condition.name,
      status: condition.status,
      diagnosedAt: condition.diagnosedAt,
      diagnosedBy: condition.diagnosedBy,
      notes: condition.notes,
      createdAt: condition.createdAt,
      updatedAt: condition.updatedAt,
      deletedAt: condition.deletedAt,
    );
  }

  static domain.Condition modelToDomain(ConditionModel model) {
    return domain.Condition(
      id: model.id,
      userId: model.userId,
      name: model.name,
      status: model.status,
      diagnosedAt: model.diagnosedAt,
      diagnosedBy: model.diagnosedBy,
      notes: model.notes,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
    );
  }

  static db.ConditionsCompanion modelToCompanion(ConditionModel model) {
    return toCompanion(modelToDomain(model));
  }

  static db.ConditionsCompanion toCompanion(domain.Condition condition) {
    return db.ConditionsCompanion(
      id: Value(condition.id),
      userId: Value(condition.userId),
      name: Value(condition.name),
      status: Value(condition.status),
      diagnosedAt: Value(condition.diagnosedAt),
      diagnosedBy: Value(condition.diagnosedBy),
      notes: Value(condition.notes),
      createdAt: Value(condition.createdAt),
      updatedAt: Value(condition.updatedAt),
      deletedAt: Value(condition.deletedAt),
    );
  }
}