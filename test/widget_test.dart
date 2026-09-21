// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.



import 'package:flutter_test/flutter_test.dart';
import 'package:mileplus/login_page.dart';

void main() {
  testWidgets('MilePlus Login Page test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const LoginPage(),
    );

    expect(find.text('MilePlus'), findsOneWidget);
    expect(find.text('Driver Login'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}