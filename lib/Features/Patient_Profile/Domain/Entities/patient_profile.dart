class PatientProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String gender;
  final String preferredLanguage;
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.gender,
    required this.preferredLanguage,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  PatientProfile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
    String? preferredLanguage,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      emergencyContactName:
      emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelationship:
      emergencyContactRelationship ?? this.emergencyContactRelationship,
      emergencyContactPhone:
      emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}