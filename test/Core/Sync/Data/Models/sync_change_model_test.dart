import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Sync/Data/Models/sync_change_model.dart';

void main() {
  test('parses created condition sync change', () {
    final model = SyncChangeModel.fromJson({
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
    });

    expect(model.entity, 'condition');
    expect(model.operation, 'created');
    expect(model.id, '28ea092d-0b1b-4080-a247-1bf0ff97f3ba');

    expect(model.data, isNotNull);
    expect(model.data!['name'], 'Migraine');
    expect(model.data!['status'], 'active');
    expect(model.data!['deletedAt'], isNull);

    expect(
      model.timestamp,
      DateTime.parse('2026-10-21T05:08:32.529Z'),
    );
  });

  test('parses deleted sync change without data', () {
    final model = SyncChangeModel.fromJson({
      'entity': 'condition',
      'operation': 'deleted',
      'id': 'condition-1',
      'data': null,
      'timestamp': '2026-10-21T06:00:00.000Z',
    });

    expect(model.entity, 'condition');
    expect(model.operation, 'deleted');
    expect(model.id, 'condition-1');
    expect(model.data, isNull);
    expect(
      model.timestamp,
      DateTime.parse('2026-10-21T06:00:00.000Z'),
    );
  });
}