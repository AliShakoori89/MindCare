import 'package:mind_care/Core/Data_Base/Dao/patient_profiles_dao.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

import 'patient_profile_local_data_source.dart';

class PatientProfileLocalDataSourceImpl
    implements PatientProfileLocalDataSource {
  final PatientProfilesDao _dao;

  PatientProfileLocalDataSourceImpl(this._dao);

  @override
  Future<void> insertProfile(PatientProfilesCompanion profile) {
    return _dao.insertProfile(profile);
  }

  @override
  Future<PatientProfile?> getProfileById(String id) {
    return _dao.getProfileById(id);
  }

  @override
  Future<PatientProfile?> getProfileByUserId(String userId) {
    return _dao.getProfileByUserId(userId);
  }

  @override
  Future<bool> updateProfile(PatientProfilesCompanion profile) {
    return _dao.updateProfile(profile);
  }

  @override
  Future<int> deleteProfile(String id) {
    return _dao.deleteProfile(id);
  }
}