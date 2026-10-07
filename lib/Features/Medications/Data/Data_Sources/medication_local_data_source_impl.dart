import 'package:mind_care/Core/Data_Base/Dao/medications_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

import 'medication_local_data_source.dart';

class MedicationLocalDataSourceImpl
    implements MedicationLocalDataSource {
  final MedicationsDao _dao;

  MedicationLocalDataSourceImpl(this._dao);

  @override
  Future<void> insertMedication(
      MedicationsCompanion medication,
      ) {
    return _dao.insertMedication(medication);
  }

  @override
  Future<Medication?> getMedicationById(
      String id,
      ) {
    return _dao.getMedicationById(id);
  }

  @override
  Future<List<Medication>> getMedicationsByUserId(
      String userId,
      ) {
    return _dao.getMedicationsByUserId(userId);
  }

  @override
  Future<bool> updateMedication(
      MedicationsCompanion medication,
      ) {
    return _dao.updateMedication(medication);
  }

  @override
  Future<int> deleteMedication(
      String id,
      ) {
    return _dao.deleteMedication(id);
  }
}