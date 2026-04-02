import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatapp/app/app.dart';

void main() {
  testWidgets('renders the login flow when no session is saved', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('renders the home shell when a session is saved', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_session':
          '{"token":"demo-token","user":{"id":1,"username":"Aaftab"}}',
    });

    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);
    expect(find.text('Calls'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Inbox overview'), findsOneWidget);
    expect(
      find.text('Your conversations, organized like a real messenger.'),
      findsOneWidget,
    );
    expect(find.text('Recent chats'), findsOneWidget);
  });

  testWidgets('shows profile details on the profile tab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_session':
          '{"token":"demo-token","user":{"id":1,"username":"Aaftab"}}',
    });

    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Aaftab'), findsWidgets);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Profile image'), findsOneWidget);
  });

  testWidgets('shows settings controls on the settings tab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_session':
          '{"token":"demo-token","user":{"id":1,"username":"Aaftab"}}',
    });

    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Font family'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Logout'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });
}
