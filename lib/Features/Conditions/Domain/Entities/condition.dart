class Condition {
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

  const Condition({
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

  Condition copyWith({
    String? id,
    String? userId,
    String? name,
    String? status,
    DateTime? diagnosedAt,
    String? diagnosedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Condition(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      status: status ?? this.status,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
      diagnosedBy: diagnosedBy ?? this.diagnosedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}