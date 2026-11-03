
import 'package:dio/dio.dart';

import '../Models/medication_model.dart';
import 'medication_remote_data_source.dart';

class MedicationRemoteDataSourceImpl
    implements MedicationRemoteDataSource {
  final Dio _dio;

  MedicationRemoteDataSourceImpl(this._dio);

  @override
  Future<MedicationModel> getMedicationById(String id) async {
    final response = await _dio.get('/medications/$id');

    return MedicationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<MedicationModel> createMedication({
    required String id,
    required String name,
    String? genericName,
    String? dosage,
    String? unit,
    required String frequencyType,
    String? frequencyValue,
    required String route,
    DateTime? startDate,
    DateTime? endDate,
    required String status,
    String? prescribedBy,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/medications',
      data: {
        'id': id,
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
      },
    );

    return MedicationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<MedicationModel> updateMedication({
    required String id,
    required String name,
    String? genericName,
    String? dosage,
    String? unit,
    required String frequencyType,
    String? frequencyValue,
    required String route,
    DateTime? startDate,
    DateTime? endDate,
    required String status,
    String? prescribedBy,
    String? notes,
  }) async {
    final response = await _dio.put(
      '/medications/$id',
      data: {
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
      },
    );

    return MedicationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteMedication(String id) async {
    await _dio.delete('/medications/$id');
  }
}
