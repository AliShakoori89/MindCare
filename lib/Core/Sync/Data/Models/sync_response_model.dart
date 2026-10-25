import 'sync_change_model.dart';

class SyncResponseModel {
  final String cursor;
  final List<SyncChangeModel> changes;

  const SyncResponseModel({required this.cursor, required this.changes});

  factory SyncResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return SyncResponseModel(
      cursor: data['cursor'] as String,
      changes: (data['changes'] as List<dynamic>)
          .map(
            (change) =>
                SyncChangeModel.fromJson(change as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
