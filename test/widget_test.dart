import 'package:flutter_test/flutter_test.dart';
import 'package:bank_churn_prediction/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChurnInsightApp());

    // Verify that the welcome text is present
    expect(find.text('Welcome Back,'), findsOneWidget);
    expect(find.text('Churn Insight AI'), findsOneWidget);
  });
}
