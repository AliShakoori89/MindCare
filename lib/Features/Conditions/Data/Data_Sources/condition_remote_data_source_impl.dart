import 'package:dio/dio.dart';

import '../Models/condition_model.dart';
import '../Models/conditions_response_model.dart';
import 'condition_remote_data_source.dart';

class ConditionRemoteDataSourceImpl implements ConditionRemoteDataSource {
  final Dio _dio;

  ConditionRemoteDataSourceImpl(this._dio);

  @override
  Future<ConditionsResponseModel> getConditions({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _dio.get(
      '/conditions',
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': ?status,
      },
    );

    return ConditionsResponseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ConditionModel> getConditionById(String id) async {
    final response = await _dio.get('/conditions/$id');

    return ConditionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ConditionModel> createCondition({
    required String name,
    required String status,
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/conditions',
      data: {
        'name': name,
        'status': status,
        'diagnosedAt': diagnosedAt?.toIso8601String(),
        'diagnosedBy': diagnosedBy,
        'notes': notes,
      },
    );

    return ConditionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ConditionModel> updateCondition({
    required String id,
    required String name,
    required String status,
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
  }) async {
    final response = await _dio.put(
      '/conditions/$id',
      data: {
        'name': name,
        'status': status,
        'diagnosedAt': diagnosedAt?.toIso8601String(),
        'diagnosedBy': diagnosedBy,
        'notes': notes,
      },
    );

    return ConditionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteCondition(String id) async {
    await _dio.delete('/conditions/$id');
  }
}
