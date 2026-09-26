import 'package:flutter_test/flutter_test.dart';
import 'package:guide_app/main.dart';

void main() {
  testWidgets('GuideApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GuideApp());
    expect(find.text('Guide Sign In'), findsOneWidget);
    expect(find.text('JOURNEY GUIDE PORTAL'), findsOneWidget);
  });
}
