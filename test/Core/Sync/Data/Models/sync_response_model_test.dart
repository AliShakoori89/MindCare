import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_response_model.dart';

void main() {
  test('parses sync response with condition change', () {
    final model = SyncResponseModel.fromJson({
      'success': true,
      'data': {
        'cursor': '2026-10-24T04:40:13.579Z',
        'changes': [
          {
            'entity': 'condition',
            'operation': 'created',
            'id': '28ea092d-0b1b-4080-a247-1bf0ff97f3ba',
            'data': {
              'id': '28ea092d-0b1b-4080-a247-1bf0ff97f3ba',
              'userId': '572ac7b0-dfd5-4088-b21b-91fb74f5199a',
              'name': 'Migraine',
              'status': 'active',
              'diagnosedAt': '2025-05-10T00:00:00.000Z',
              'diagnosedBy': 'Dr. Jane Smith',
              'notes': 'Occurs primarily in low light conditions',
              'createdAt': '2026-10-21T05:08:32.529Z',
              'updatedAt': '2026-10-21T05:08:32.529Z',
              'deletedAt': null,
            },
            'timestamp': '2026-10-21T05:08:32.529Z',
          },
        ],
      },
      'message': null,
    });

    expect(model.cursor, '2026-10-24T04:40:13.579Z');
    expect(model.changes, hasLength(1));

    final change = model.changes.first;

    expect(change.entity, 'condition');
    expect(change.operation, 'created');
    expect(
      change.id,
      '28ea092d-0b1b-4080-a247-1bf0ff97f3ba',
    );
    expect(change.data!['name'], 'Migraine');
  });

  test('parses sync response with empty changes', () {
    final model = SyncResponseModel.fromJson({
      'success': true,
      'data': {
        'cursor': '2026-10-24T04:40:13.579Z',
        'changes': [],
      },
      'message': null,
    });

    expect(model.cursor, '2026-10-24T04:40:13.579Z');
    expect(model.changes, isEmpty);
  });
}