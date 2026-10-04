import 'package:flutter_test/flutter_test.dart';
import 'package:mind_care/app/app.dart';

void main() {
  testWidgets('MindCare app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MindCareApp());

    expect(find.text('MindCare'), findsOneWidget);
  });
}
