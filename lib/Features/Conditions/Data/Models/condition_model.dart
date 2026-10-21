class ConditionModel {
  final String id;
  final String userId;
  final String name;
  final String status;
  final DateTime? diagnosedAt;
  final String? diagnosedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ConditionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    this.diagnosedAt,
    this.diagnosedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      diagnosedAt: json['diagnosedAt'] == null
          ? null
          : DateTime.parse(json['diagnosedAt'] as String),
      diagnosedBy: json['diagnosedBy'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'status': status,
      'diagnosedAt': diagnosedAt?.toIso8601String(),
      'diagnosedBy': diagnosedBy,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
