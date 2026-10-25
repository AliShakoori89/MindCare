import '../Models/sync_response_model.dart';

abstract interface class SyncRemoteDataSource {
  Future<SyncResponseModel> getChanges({String? cursor});
}
