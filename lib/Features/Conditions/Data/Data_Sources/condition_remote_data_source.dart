import '../Models/condition_model.dart';
import '../Models/conditions_response_model.dart';

abstract interface class ConditionRemoteDataSource {
  Future<ConditionsResponseModel> getConditions({
    int page = 1,
    int limit = 20,
    String? status,
  });

  Future<ConditionModel> getConditionById(String id);

  Future<ConditionModel> createCondition({
    required String name,
    required String status,
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
  });

  Future<ConditionModel> updateCondition({
    required String id,
    required String name,
    required String status,
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
  });

  Future<void> deleteCondition(String id);
}
