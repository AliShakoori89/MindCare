import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_local_data_source.dart';
import 'package:mind_care/Features/Medications/Data/Mappers/medication_mapper.dart';
import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';

class MedicationRepositoryImpl
    implements MedicationRepository {
  final MedicationLocalDataSource _localDataSource;

  MedicationRepositoryImpl(this._localDataSource);

  @override
  Future<void> createMedication(
      Medication medication,
      ) {
    return _localDataSource.insertMedication(
      MedicationMapper.toCompanion(medication),
    );
  }

  @override
  Future<Medication?> getMedicationById(
      String id,
      ) async {
    final medication =
    await _localDataSource.getMedicationById(id);

    if (medication == null) {
      return null;
    }

    return MedicationMapper.toDomain(medication);
  }

  @override
  Future<List<Medication>> getMedicationsByUserId(
      String userId,
      ) async {
    final medications =
    await _localDataSource.getMedicationsByUserId(userId);

    return medications
        .map(MedicationMapper.toDomain)
        .toList();
  }

  @override
  Future<void> updateMedication(
      Medication medication,
      ) {
    return _localDataSource.updateMedication(
      MedicationMapper.toCompanion(medication),
    );
  }

  @override
  Future<void> deleteMedication(
      String id,
      ) async {
    await _localDataSource.deleteMedication(id);
  }
}