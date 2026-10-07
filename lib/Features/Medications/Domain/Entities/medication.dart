class Medication {
  final String id;
  final String userId;

  final String name;
  final String? genericName;

  final String? dosage;
  final String? unit;

  final String frequencyType;
  final String? frequencyValue;

  final String route;

  final DateTime? startDate;
  final DateTime? endDate;

  final String status;
  final String? prescribedBy;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    this.genericName,
    this.dosage,
    this.unit,
    required this.frequencyType,
    this.frequencyValue,
    required this.route,
    this.startDate,
    this.endDate,
    required this.status,
    this.prescribedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? genericName,
    String? dosage,
    String? unit,
    String? frequencyType,
    String? frequencyValue,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? prescribedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}