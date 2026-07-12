import 'package:flutter_test/flutter_test.dart';
import 'package:technopark_app/main.dart';
import 'package:technopark_app/services/notification_service.dart';

void main() {
  testWidgets('shows TechnoPark splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      TechnoParkApp(notificationService: NotificationService()),
    );

    expect(find.text('TechnoPark'), findsOneWidget);
  });
}
