import 'package:drift/native.dart';
import 'package:mind_care/Core/Data_Base/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    NativeDatabase.memory(),
  );
}