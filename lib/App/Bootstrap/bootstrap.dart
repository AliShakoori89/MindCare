import 'package:flutter/widgets.dart';
import 'package:mind_care/App/app.dart';
import 'package:mind_care/Core/DI/injection.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  runApp(const MindCareApp());
}