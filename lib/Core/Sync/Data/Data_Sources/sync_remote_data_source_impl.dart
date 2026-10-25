import 'package:dio/dio.dart';

import '../Models/sync_response_model.dart';
import 'sync_remote_data_source.dart';

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  final Dio _dio;

  SyncRemoteDataSourceImpl(this._dio);

  @override
  Future<SyncResponseModel> getChanges({String? cursor}) async {
    final response = await _dio.get(
      '/sync',
      queryParameters: {'cursor': ?cursor},
    );

    return SyncResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
