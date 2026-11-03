
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Medications/Data/Data_Sources/medication_remote_data_source_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late MedicationRemoteDataSourceImpl dataSource;

  const medicationResponse = {
    'id': 'medication-1',
    'userId': 'user-1',
    'name': 'Ibuprofen',
    'genericName': 'Ibuprofen',
    'dosage': '200',
    'unit': 'mg',
    'frequencyType': 'daily',
    'frequencyValue': '2',
    'route': 'oral',
    'startDate': '2026-10-01T00:00:00.000Z',
    'endDate': '2026-10-10T00:00:00.000Z',
    'status': 'active',
    'prescribedBy': 'Dr. Smith',
    'notes': 'Take after meals',
    'createdAt': '2026-10-21T05:08:32.529Z',
    'updatedAt': '2026-10-21T05:08:32.529Z',
    'deletedAt': null,
  };

  setUp(() {
    dio = MockDio();
    dataSource = MedicationRemoteDataSourceImpl(dio);
  });

  group('getMedicationById', () {
    test('returns parsed medication', () async {
      when(
        () => dio.get('/medications/medication-1'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: '/medications/medication-1',
          ),
          data: {
            'success': true,
            'data': medicationResponse,
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getMedicationById('medication-1');

      expect(result.id, 'medication-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Ibuprofen');
      expect(result.genericName, 'Ibuprofen');
      expect(result.dosage, '200');
      expect(result.unit, 'mg');
      expect(result.frequencyType, 'daily');
      expect(result.frequencyValue, '2');
      expect(result.route, 'oral');
      expect(result.status, 'active');
      expect(result.prescribedBy, 'Dr. Smith');
      expect(result.notes, 'Take after meals');

      verify(
        () => dio.get('/medications/medication-1'),
      ).called(1);
    });
  });

  group('createMedication', () {
    test('sends correct request body and returns created medication',
        () async {
      final startDate = DateTime.utc(2026, 10, 1);
      final endDate = DateTime.utc(2026, 10, 10);

      final requestBody = {
        'id': 'medication-123',
        'name': 'Ibuprofen',
        'genericName': 'Ibuprofen',
        'dosage': '200',
        'unit': 'mg',
        'frequencyType': 'daily',
        'frequencyValue': '2',
        'route': 'oral',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': 'active',
        'prescribedBy': 'Dr. Smith',
        'notes': 'Take after meals',
      };

      when(
        () => dio.post('/medications', data: requestBody),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/medications'),
          data: {
            'success': true,
            'data': medicationResponse,
            'message': null,
          },
          statusCode: 201,
        ),
      );

      final result = await dataSource.createMedication(
        id: 'medication-123',
        name: 'Ibuprofen',
        genericName: 'Ibuprofen',
        dosage: '200',
        unit: 'mg',
        frequencyType: 'daily',
        frequencyValue: '2',
        route: 'oral',
        startDate: startDate,
        endDate: endDate,
        status: 'active',
        prescribedBy: 'Dr. Smith',
        notes: 'Take after meals',
      );

      expect(result.id, 'medication-1');
      expect(result.name, 'Ibuprofen');
      expect(result.status, 'active');

      verify(
        () => dio.post('/medications', data: requestBody),
      ).called(1);
    });

    test('sends null for optional fields when omitted', () async {
      final requestBody = {
        'id': 'medication-123',
        'name': 'Ibuprofen',
        'genericName': null,
        'dosage': null,
        'unit': null,
        'frequencyType': 'daily',
        'frequencyValue': null,
        'route': 'oral',
        'startDate': null,
        'endDate': null,
        'status': 'active',
        'prescribedBy': null,
        'notes': null,
      };

      when(
        () => dio.post('/medications', data: requestBody),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/medications'),
          data: {
            'success': true,
            'data': medicationResponse,
            'message': null,
          },
          statusCode: 201,
        ),
      );

      final result = await dataSource.createMedication(
        id: 'medication-123',
        name: 'Ibuprofen',
        frequencyType: 'daily',
        route: 'oral',
        status: 'active',
      );

      expect(result.id, 'medication-1');

      verify(
        () => dio.post('/medications', data: requestBody),
      ).called(1);
    });
  });

  group('updateMedication', () {
    test('sends correct request body and returns updated medication',
        () async {
      final startDate = DateTime.utc(2026, 10, 1);
      final endDate = DateTime.utc(2026, 10, 10);

      final requestBody = {
        'name': 'Ibuprofen Updated',
        'genericName': 'Ibuprofen',
        'dosage': '400',
        'unit': 'mg',
        'frequencyType': 'daily',
        'frequencyValue': '1',
        'route': 'oral',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': 'inactive',
        'prescribedBy': 'Dr. Smith',
        'notes': 'Updated note',
      };

      when(
        () => dio.put(
          '/medications/medication-1',
          data: requestBody,
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: '/medications/medication-1',
          ),
          data: {
            'success': true,
            'data': {
              ...medicationResponse,
              'name': 'Ibuprofen Updated',
              'dosage': '400',
              'frequencyValue': '1',
              'status': 'inactive',
              'notes': 'Updated note',
            },
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.updateMedication(
        id: 'medication-1',
        name: 'Ibuprofen Updated',
        genericName: 'Ibuprofen',
        dosage: '400',
        unit: 'mg',
        frequencyType: 'daily',
        frequencyValue: '1',
        route: 'oral',
        startDate: startDate,
        endDate: endDate,
        status: 'inactive',
        prescribedBy: 'Dr. Smith',
        notes: 'Updated note',
      );

      expect(result.id, 'medication-1');
      expect(result.name, 'Ibuprofen Updated');
      expect(result.dosage, '400');
      expect(result.status, 'inactive');
      expect(result.notes, 'Updated note');

      verify(
        () => dio.put(
          '/medications/medication-1',
          data: requestBody,
        ),
      ).called(1);
    });

    test('sends null for omitted optional fields', () async {
      final requestBody = {
        'name': 'Ibuprofen',
        'genericName': null,
        'dosage': null,
        'unit': null,
        'frequencyType': 'daily',
        'frequencyValue': null,
        'route': 'oral',
        'startDate': null,
        'endDate': null,
        'status': 'active',
        'prescribedBy': null,
        'notes': null,
      };

      when(
        () => dio.put(
          '/medications/medication-1',
          data: requestBody,
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: '/medications/medication-1',
          ),
          data: {
            'success': true,
            'data': medicationResponse,
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.updateMedication(
        id: 'medication-1',
        name: 'Ibuprofen',
        frequencyType: 'daily',
        route: 'oral',
        status: 'active',
      );

      expect(result.id, 'medication-1');

      verify(
        () => dio.put(
          '/medications/medication-1',
          data: requestBody,
        ),
      ).called(1);
    });
  });

  group('deleteMedication', () {
    test('sends delete request', () async {
      when(
        () => dio.delete('/medications/medication-1'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: '/medications/medication-1',
          ),
          statusCode: 200,
        ),
      );

      await dataSource.deleteMedication('medication-1');

      verify(
        () => dio.delete('/medications/medication-1'),
      ).called(1);
    });
  });
}
