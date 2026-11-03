
class MedicationModel {
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

  const MedicationModel({
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

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String?,
      dosage: json['dosage'] as String?,
      unit: json['unit'] as String?,
      frequencyType: json['frequencyType'] as String,
      frequencyValue: json['frequencyValue'] as String?,
      route: json['route'] as String,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      prescribedBy: json['prescribedBy'] as String?,
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
      'genericName': genericName,
      'dosage': dosage,
      'unit': unit,
      'frequencyType': frequencyType,
      'frequencyValue': frequencyValue,
      'route': route,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'prescribedBy': prescribedBy,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
