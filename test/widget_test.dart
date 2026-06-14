import 'package:flutter_test/flutter_test.dart';
import 'package:technopark_app/main.dart';

void main() {
  testWidgets('shows TechnoPark login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TechnoParkApp());

    expect(find.text('TechnoPark'), findsOneWidget);
    expect(find.text('Masuk untuk booking workspace'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
