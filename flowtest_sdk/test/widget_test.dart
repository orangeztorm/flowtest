// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowtest_sdk/main.dart';

void main() {
  testWidgets('FlowTest Demo App login flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlowTestDemoApp());

    // Verify that we start with the login screen
    expect(find.text('FlowTest SDK Demo Login'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // Enter email and password
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );

    // Tap the login button
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Verify that we're now logged in
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Logged in as: test@example.com'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // Counter starts at 0

    // Test the counter functionality
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pump();

    // Verify that counter incremented
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
