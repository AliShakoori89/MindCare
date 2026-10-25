class SyncChangeModel {
  final String entity;
  final String operation;
  final String id;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const SyncChangeModel({
    required this.entity,
    required this.operation,
    required this.id,
    required this.data,
    required this.timestamp,
  });

  factory SyncChangeModel.fromJson(Map<String, dynamic> json) {
    return SyncChangeModel(
      entity: json['entity'] as String,
      operation: json['operation'] as String,
      id: json['id'] as String,
      data: json['data'] == null
          ? null
          : Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
