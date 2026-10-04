import 'package:flutter/widgets.dart';
import 'package:mind_care/app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MindCareApp());
}
