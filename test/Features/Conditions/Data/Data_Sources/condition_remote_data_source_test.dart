import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Conditions/Data/Data_Sources/condition_remote_data_source_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ConditionRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = ConditionRemoteDataSourceImpl(dio);
  });

  group('getConditions', () {
    test('returns parsed conditions response', () async {
      when(
        () => dio.get('/conditions', queryParameters: {'page': 1, 'limit': 20}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions'),
          data: {
            'success': true,
            'data': {
              'items': [
                {
                  'id': 'condition-1',
                  'userId': 'user-1',
                  'name': 'Migraine',
                  'status': 'active',
                  'diagnosedAt': '2025-05-10T00:00:00.000Z',
                  'diagnosedBy': 'Dr. Jane Smith',
                  'notes': 'Test note',
                  'createdAt': '2026-10-21T05:08:32.529Z',
                  'updatedAt': '2026-10-21T05:08:32.529Z',
                  'deletedAt': null,
                },
              ],
              'page': 1,
              'limit': 20,
              'total': 1,
              'totalPages': 1,
            },
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getConditions();

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 'condition-1');
      expect(result.items.first.name, 'Migraine');
      expect(result.items.first.status, 'active');
      expect(result.page, 1);
      expect(result.limit, 20);
      expect(result.total, 1);
      expect(result.totalPages, 1);

      verify(
        () => dio.get('/conditions', queryParameters: {'page': 1, 'limit': 20}),
      ).called(1);
    });

    test('sends status filter when provided', () async {
      when(
        () => dio.get(
          '/conditions',
          queryParameters: {'page': 2, 'limit': 10, 'status': 'active'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions'),
          data: {
            'success': true,
            'data': {
              'items': [],
              'page': 2,
              'limit': 10,
              'total': 0,
              'totalPages': 0,
            },
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getConditions(
        page: 2,
        limit: 10,
        status: 'active',
      );

      expect(result.items, isEmpty);

      verify(
        () => dio.get(
          '/conditions',
          queryParameters: {'page': 2, 'limit': 10, 'status': 'active'},
        ),
      ).called(1);
    });
  });

  group('getConditionById', () {
    test('returns parsed condition', () async {
      when(() => dio.get('/conditions/condition-1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions/condition-1'),
          data: {
            'success': true,
            'data': {
              'id': 'condition-1',
              'userId': 'user-1',
              'name': 'Migraine',
              'status': 'active',
              'diagnosedAt': null,
              'diagnosedBy': null,
              'notes': null,
              'createdAt': '2026-10-21T05:08:32.529Z',
              'updatedAt': '2026-10-21T05:08:32.529Z',
              'deletedAt': null,
            },
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getConditionById('condition-1');

      expect(result.id, 'condition-1');
      expect(result.userId, 'user-1');
      expect(result.name, 'Migraine');
      expect(result.status, 'active');

      verify(() => dio.get('/conditions/condition-1')).called(1);
    });
  });

  group('createCondition', () {
    test('sends correct request body and returns created condition', () async {
      final diagnosedAt = DateTime.utc(2025, 5, 10);

      when(
        () => dio.post(
          '/conditions',
          data: {
            'id': 'condition-123',
            'name': 'Migraine',
            'status': 'active',
            'diagnosedAt': diagnosedAt.toIso8601String(),
            'diagnosedBy': 'Dr. Jane Smith',
            'notes': 'Test note',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions'),
          data: {
            'success': true,
            'data': {
              'id': 'condition-1',
              'userId': 'user-1',
              'name': 'Migraine',
              'status': 'active',
              'diagnosedAt': diagnosedAt.toIso8601String(),
              'diagnosedBy': 'Dr. Jane Smith',
              'notes': 'Test note',
              'createdAt': '2026-10-21T05:08:32.529Z',
              'updatedAt': '2026-10-21T05:08:32.529Z',
              'deletedAt': null,
            },
            'message': null,
          },
          statusCode: 201,
        ),
      );

      final result = await dataSource.createCondition(
        id: 'condition-123',
        name: 'Migraine',
        status: 'active',
        diagnosedAt: diagnosedAt,
        diagnosedBy: 'Dr. Jane Smith',
        notes: 'Test note',
      );

      expect(result.id, 'condition-1');
      expect(result.name, 'Migraine');

      verify(
        () => dio.post(
          '/conditions',
          data: {
            'id': 'condition-123',
            'name': 'Migraine',
            'status': 'active',
            'diagnosedAt': diagnosedAt.toIso8601String(),
            'diagnosedBy': 'Dr. Jane Smith',
            'notes': 'Test note',
          },
        ),
      ).called(1);
    });
  });

  group('updateCondition', () {
    test('sends correct request body and returns updated condition', () async {
      when(
        () => dio.put(
          '/conditions/condition-1',
          data: {
            'name': 'Migraine Updated',
            'status': 'inactive',
            'diagnosedAt': null,
            'diagnosedBy': 'Dr. Smith',
            'notes': 'Updated note',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions/condition-1'),
          data: {
            'success': true,
            'data': {
              'id': 'condition-1',
              'userId': 'user-1',
              'name': 'Migraine Updated',
              'status': 'inactive',
              'diagnosedAt': null,
              'diagnosedBy': 'Dr. Smith',
              'notes': 'Updated note',
              'createdAt': '2026-10-21T05:08:32.529Z',
              'updatedAt': '2026-10-21T06:08:32.529Z',
              'deletedAt': null,
            },
            'message': null,
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.updateCondition(
        id: 'condition-1',
        name: 'Migraine Updated',
        status: 'inactive',
        diagnosedBy: 'Dr. Smith',
        notes: 'Updated note',
      );

      expect(result.id, 'condition-1');
      expect(result.name, 'Migraine Updated');
      expect(result.status, 'inactive');

      verify(
        () => dio.put(
          '/conditions/condition-1',
          data: {
            'name': 'Migraine Updated',
            'status': 'inactive',
            'diagnosedAt': null,
            'diagnosedBy': 'Dr. Smith',
            'notes': 'Updated note',
          },
        ),
      ).called(1);
    });
  });

  group('deleteCondition', () {
    test('sends delete request', () async {
      when(() => dio.delete('/conditions/condition-1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/conditions/condition-1'),
          statusCode: 200,
        ),
      );

      await dataSource.deleteCondition('condition-1');

      verify(() => dio.delete('/conditions/condition-1')).called(1);
    });
  });
}
