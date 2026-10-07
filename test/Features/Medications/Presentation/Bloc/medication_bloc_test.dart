import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Features/Medications/Domain/Entities/medication.dart';
import 'package:mind_care/Features/Medications/Domain/Repositories/medication_repository.dart';
import 'package:mind_care/Features/Medications/Domain/Use_Cases/create_medication.dart';
import 'package:mind_care/Features/Medications/Domain/Use_Cases/delete_medication.dart';
import 'package:mind_care/Features/Medications/Domain/Use_Cases/get_medication_by_id.dart';
import 'package:mind_care/Features/Medications/Domain/Use_Cases/get_medications_by_user_id.dart';
import 'package:mind_care/Features/Medications/Domain/Use_Cases/update_medication.dart';
import 'package:mind_care/Features/Medications/Presentation/Bloc/medication_bloc.dart';
import 'package:mind_care/Features/Medications/Presentation/Bloc/medication_event.dart';
import 'package:mind_care/Features/Medications/Presentation/Bloc/medication_state.dart';

class FakeMedicationRepository implements MedicationRepository {
  bool shouldThrow = false;

  final List<Medication> medications = [];

  @override
  Future<void> createMedication(
      Medication medication,
      ) async {
    if (shouldThrow) {
      throw Exception('Create medication failed');
    }

    medications.add(medication);
  }

  @override
  Future<Medication?> getMedicationById(
      String id,
      ) async {
    if (shouldThrow) {
      throw Exception('Get medication failed');
    }

    try {
      return medications.firstWhere(
            (medication) => medication.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Medication>> getMedicationsByUserId(
      String userId,
      ) async {
    if (shouldThrow) {
      throw Exception('Get medications failed');
    }

    return medications
        .where(
          (medication) => medication.userId == userId,
    )
        .toList();
  }

  @override
  Future<void> updateMedication(
      Medication medication,
      ) async {
    if (shouldThrow) {
      throw Exception('Update medication failed');
    }

    final index = medications.indexWhere(
          (item) => item.id == medication.id,
    );

    if (index == -1) {
      throw Exception('Medication not found');
    }

    medications[index] = medication;
  }

  @override
  Future<void> deleteMedication(
      String id,
      ) async {
    if (shouldThrow) {
      throw Exception('Delete medication failed');
    }

    medications.removeWhere(
          (medication) => medication.id == id,
    );
  }
}

void main() {
  late FakeMedicationRepository repository;
  late MedicationBloc bloc;

  const userId = 'user-1';
  const medicationId = 'medication-1';

  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 1);

  Medication createMedication({
    String name = 'Aspirin',
    String status = 'active',
  }) {
    return Medication(
      id: medicationId,
      userId: userId,
      name: name,
      genericName: 'Acetylsalicylic Acid',
      dosage: '100',
      unit: 'mg',
      frequencyType: 'daily',
      frequencyValue: '1',
      route: 'oral',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      status: status,
      prescribedBy: 'Dr. Test',
      notes: 'Test medication',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  setUp(() {
    repository = FakeMedicationRepository();

    bloc = MedicationBloc(
      CreateMedication(repository),
      GetMedicationById(repository),
      GetMedicationsByUserId(repository),
      UpdateMedication(repository),
      DeleteMedication(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('CreateMedicationEvent', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Created] when medication is created successfully',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          CreateMedicationEvent(
            createMedication(),
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationCreated>(),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when creating medication fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          CreateMedicationEvent(
            createMedication(),
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          contains('Create medication failed'),
        ),
      ],
    );
  });

  group('GetMedicationByIdEvent', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Loaded] when medication exists',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMedicationByIdEvent(
            medicationId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationLoaded>().having(
              (state) => state.medication.id,
          'medication.id',
          medicationId,
        ),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when medication does not exist',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const GetMedicationByIdEvent(
            medicationId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          'Medication not found',
        ),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when getting medication fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMedicationByIdEvent(
            medicationId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          contains('Get medication failed'),
        ),
      ],
    );
  });

  group('GetMedicationsByUserIdEvent', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, MedicationsLoaded] when medications are loaded',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMedicationsByUserIdEvent(
            userId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationsLoaded>().having(
              (state) => state.medications.length,
          'medications.length',
          1,
        ),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when getting medications fails',
      build: () {
        repository.shouldThrow = true;
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const GetMedicationsByUserIdEvent(
            userId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          contains('Get medications failed'),
        ),
      ],
    );
  });

  group('UpdateMedicationEvent', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Updated] when medication is updated successfully',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          UpdateMedicationEvent(
            createMedication(
              name: 'Aspirin Updated',
            ),
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationUpdated>(),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when updating medication fails',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        repository.shouldThrow = true;

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          UpdateMedicationEvent(
            createMedication(
              name: 'Aspirin Updated',
            ),
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          contains('Update medication failed'),
        ),
      ],
    );
  });

  group('DeleteMedicationEvent', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Deleted] when medication is deleted successfully',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const DeleteMedicationEvent(
            medicationId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationDeleted>(),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, Error] when deleting medication fails',
      build: () {
        repository.medications.add(
          createMedication(),
        );

        repository.shouldThrow = true;

        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const DeleteMedicationEvent(
            medicationId,
          ),
        );
      },
      expect: () => [
        isA<MedicationLoading>(),
        isA<MedicationError>().having(
              (state) => state.message,
          'message',
          contains('Delete medication failed'),
        ),
      ],
    );
  });
}