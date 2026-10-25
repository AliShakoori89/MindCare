import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Data_Sources/sync_remote_data_source_impl.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_response_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SyncRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = SyncRemoteDataSourceImpl(dio);
  });

  test('getChanges sends request without cursor for initial sync', () async {
    when(
          () => dio.get(
        '/sync',
        queryParameters: <String, dynamic>{},
      ),
    ).thenAnswer(
          (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync'),
        data: {
          'success': true,
          'data': {
            'cursor': '2026-10-24T04:40:13.579Z',
            'changes': [],
          },
          'message': null,
        },
      ),
    );

    final result = await dataSource.getChanges();

    expect(result, isA<SyncResponseModel>());
    expect(result.cursor, '2026-10-24T04:40:13.579Z');
    expect(result.changes, isEmpty);

    verify(
          () => dio.get(
        '/sync',
        queryParameters: <String, dynamic>{},
      ),
    ).called(1);
  });

  test('getChanges sends cursor for incremental sync', () async {
    const cursor = '2026-10-24T04:00:00.000Z';

    when(
          () => dio.get(
        '/sync',
        queryParameters: {'cursor': cursor},
      ),
    ).thenAnswer(
          (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync'),
        data: {
          'success': true,
          'data': {
            'cursor': '2026-10-24T04:40:13.579Z',
            'changes': [],
          },
          'message': null,
        },
      ),
    );

    final result = await dataSource.getChanges(cursor: cursor);

    expect(result.cursor, '2026-10-24T04:40:13.579Z');

    verify(
          () => dio.get(
        '/sync',
        queryParameters: {'cursor': cursor},
      ),
    ).called(1);
  });
}