import 'package:drift/drift.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart' as db;
import 'package:mind_care/Features/Patient_Profile/Domain/Entities/patient_profile.dart'
as domain;

extension PatientProfileModelMapper on db.PatientProfile {
  domain.PatientProfile toDomain() {
    return domain.PatientProfile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      gender: gender,
      preferredLanguage: preferredLanguage,
      emergencyContactName: emergencyContactName,
      emergencyContactRelationship: emergencyContactRelationship,
      emergencyContactPhone: emergencyContactPhone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension PatientProfileEntityMapper on domain.PatientProfile {
  db.PatientProfilesCompanion toCompanion() {
    return db.PatientProfilesCompanion.insert(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      birthDate: Value(birthDate),
      gender: gender,
      preferredLanguage: preferredLanguage,
      emergencyContactName: Value(emergencyContactName),
      emergencyContactRelationship: Value(emergencyContactRelationship),
      emergencyContactPhone: Value(emergencyContactPhone),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}