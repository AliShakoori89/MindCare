import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Repositories/daily_check_in_repository.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/create_daily_check_in.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/delete_daily_check_in.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_id.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_in_by_user_and_date.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/get_daily_check_ins_by_user_id.dart';
import 'package:mind_care/Features/Daily_Checkin/Domain/Use_Cases/update_daily_check_in.dart';
import 'package:mind_care/Features/Daily_Checkin/Presentation/Bloc/Daily_Check_In_Bloc/daily_check_in_bloc.dart';
import 'package:mind_care/Features/Daily_Checkin/Presentation/Bloc/Daily_Check_In_Bloc/daily_check_in_event.dart';
import 'package:mind_care/Features/Daily_Checkin/Presentation/Bloc/Daily_Check_In_Bloc/daily_check_in_state.dart';

class FakeDailyCheckInRepository implements DailyCheckInRepository {
  final Map<String, DailyCheckIn> items = {};

  @override
  Future<void> createDailyCheckIn(DailyCheckIn checkIn) async {
    items[checkIn.id] = checkIn;
  }

  @override
  Future<DailyCheckIn?> getDailyCheckInById(String id) async =>
      items[id];

  @override
  Future<DailyCheckIn?> getDailyCheckInByUserAndDate(
      String userId,
      DateTime date,
      ) async {
    for (final item in items.values) {
      if (item.userId == userId &&
          item.date.year == date.year &&
          item.date.month == date.month &&
          item.date.day == date.day) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckInsByUserId(
      String userId,
      ) async =>
      items.values.where((item) => item.userId == userId).toList();

  @override
  Future<void> updateDailyCheckIn(DailyCheckIn checkIn) async {
    if (items.containsKey(checkIn.id)) {
      items[checkIn.id] = checkIn;
    }
  }

  @override
  Future<void> deleteDailyCheckIn(String id) async {
    items.remove(id);
  }
}

void main() {
  late FakeDailyCheckInRepository repository;
  late DailyCheckInBloc bloc;

  final now = DateTime(2026, 10, 5, 10);

  final checkIn = DailyCheckIn(
    id: 'check-in-1',
    userId: 'user-1',
    date: DateTime(2026, 10, 5),
    mood: 4,
    anxiety: 2,
    energy: 3,
    stress: 2,
    sleepDurationMinutes: 420,
    sleepQuality: 4,
    activityLevel: 'moderate',
    note: 'Feeling good',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );

  setUp(() {
    repository = FakeDailyCheckInRepository();

    bloc = DailyCheckInBloc(
      createDailyCheckIn: CreateDailyCheckIn(repository),
      getDailyCheckInById: GetDailyCheckInById(repository),
      getDailyCheckInByUserAndDate:
      GetDailyCheckInByUserAndDate(repository),
      getDailyCheckInsByUserId: GetDailyCheckInsByUserId(repository),
      updateDailyCheckIn: UpdateDailyCheckIn(repository),
      deleteDailyCheckIn: DeleteDailyCheckIn(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  blocTest<DailyCheckInBloc, DailyCheckInState>(
    'creates a check-in successfully',
    build: () => bloc,
    act: (bloc) => bloc.add(CreateDailyCheckInEvent(checkIn)),
    expect: () => [
      isA<DailyCheckInLoading>(),
      isA<DailyCheckInOperationSuccess>(),
    ],
    verify: (_) {
      expect(repository.items.containsKey(checkIn.id), isTrue);
    },
  );

  blocTest<DailyCheckInBloc, DailyCheckInState>(
    'loads an existing check-in by id',
    build: () {
      repository.items[checkIn.id] = checkIn;
      return bloc;
    },
    act: (bloc) => bloc.add(
      const LoadDailyCheckInByIdEvent('check-in-1'),
    ),
    expect: () => [
      isA<DailyCheckInLoading>(),
      isA<DailyCheckInLoaded>(),
    ],
  );

  blocTest<DailyCheckInBloc, DailyCheckInState>(
    'emits not-found when check-in does not exist',
    build: () => bloc,
    act: (bloc) => bloc.add(
      const LoadDailyCheckInByIdEvent('missing-id'),
    ),
    expect: () => [
      isA<DailyCheckInLoading>(),
      isA<DailyCheckInNotFound>(),
    ],
  );

  blocTest<DailyCheckInBloc, DailyCheckInState>(
    'loads the user check-in history',
    build: () {
      repository.items[checkIn.id] = checkIn;
      return bloc;
    },
    act: (bloc) => bloc.add(
      const LoadDailyCheckInsByUserIdEvent('user-1'),
    ),
    expect: () => [
      isA<DailyCheckInLoading>(),
      isA<DailyCheckInsLoaded>(),
    ],
  );

  blocTest<DailyCheckInBloc, DailyCheckInState>(
    'deletes a check-in successfully',
    build: () {
      repository.items[checkIn.id] = checkIn;
      return bloc;
    },
    act: (bloc) => bloc.add(
      const DeleteDailyCheckInEvent('check-in-1'),
    ),
    expect: () => [
      isA<DailyCheckInLoading>(),
      isA<DailyCheckInOperationSuccess>(),
    ],
    verify: (_) {
      expect(repository.items.containsKey(checkIn.id), isFalse);
    },
  );
}