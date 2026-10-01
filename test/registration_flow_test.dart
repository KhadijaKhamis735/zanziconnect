import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanzi_connect/main.dart';
import 'package:zanzi_connect/models/registered_account.dart';

void main() {
  setUp(DemoAccountStore.logout);

  testWidgets('Visitor registration preserves role and opens Login',
      (tester) async {
    await tester.pumpWidget(const ZanziApp());
    await _openRegistration(tester);
    await _fillForm(tester, role: 'Visitor');

    expect(
        find.text(
            'Discover and book Zanzibar tourism and coastal experiences.'),
        findsOneWidget);
    await _submit(tester);

    _expectCleanLogin(tester, 'visitor@example.com');
    await _login(tester, 'visitor@example.com', 'demo-pass');
    expect(find.byType(NavigationBar), findsOneWidget);
    await _logout(tester);
  });

  testWidgets('Provider registration preserves role and opens Login',
      (tester) async {
    await tester.pumpWidget(const ZanziApp());
    await _openRegistration(tester);
    await _fillForm(tester, role: 'Provider');

    expect(
      find.text(
          'List and manage tourism or coastal experiences on ZanziConnect.'),
      findsOneWidget,
    );
    await _submit(tester);

    _expectCleanLogin(tester, 'provider@example.com');
    await _login(tester, 'provider@example.com', 'demo-pass');
    expect(find.text('ZanziConnect Provider'), findsOneWidget);
    expect(find.text('PROFILE SETUP REQUIRED'), findsOneWidget);
    expect(find.text('No experiences yet.'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byKey(const Key('provider_navigation_4')));
    await tester.pumpAndSettle();
    expect(find.text('PROVIDER'), findsOneWidget);
    await _logout(tester);
  });

  testWidgets('registration validates required fields and password match',
      (tester) async {
    await tester.pumpWidget(const ZanziApp());
    await _openRegistration(tester);
    await _submit(tester);
    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Select your role.'), findsOneWidget);

    await _fillForm(tester, role: 'Visitor', passwordsMatch: false);
    await _submit(tester);
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('invalid password is rejected with a friendly error',
      (tester) async {
    await tester.pumpWidget(const ZanziApp());
    await _openRegistration(tester);
    await _fillForm(tester, role: 'Visitor', email: 'invalid@example.com');
    await _submit(tester);
    _expectCleanLogin(tester, 'invalid@example.com');
    await tester.ensureVisible(find.byKey(const Key('login_password_field')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'invalid@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'incorrect-password',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}

Future<void> _openRegistration(WidgetTester tester) async {
  await tester.ensureVisible(find.text('CREATE ACCOUNT'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('CREATE ACCOUNT'));
  await tester.pumpAndSettle();
}

Future<void> _fillForm(
  WidgetTester tester, {
  required String role,
  String? email,
  bool passwordsMatch = true,
}) async {
  await tester.enterText(find.byKey(const Key('full_name_field')), 'Demo User');
  await tester.enterText(
    find.byKey(const Key('email_field')),
    email ??
        (role == 'Visitor' ? 'visitor@example.com' : 'provider@example.com'),
  );
  await tester.enterText(find.byKey(const Key('phone_field')), '+255712345678');
  await tester.enterText(find.byKey(const Key('password_field')), 'demo-pass');
  await tester.enterText(
    find.byKey(const Key('confirm_password_field')),
    passwordsMatch ? 'demo-pass' : 'different-pass',
  );
  await tester.ensureVisible(find.byKey(const Key('role_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('role_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(role).last);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('create_account_button')));
  await tester.tap(find.byKey(const Key('create_account_button')));
  await tester.pumpAndSettle();
}

void _expectCleanLogin(WidgetTester tester, String registeredEmail) {
  expect(find.text('Welcome Back'), findsOneWidget);
  expect(find.text('Log in to continue your ZanziConnect journey.'),
      findsOneWidget);
  expect(find.text('ACCOUNT DETAILS'), findsNothing);
  expect(find.text('Account created successfully.'), findsNothing);
  expect(find.text('Demo User'), findsNothing);
  expect(find.text('Phone: +255712345678'), findsNothing);
  expect(find.text('Role: VISITOR'), findsNothing);
  expect(find.text('Role: PROVIDER'), findsNothing);
  expect(find.text(registeredEmail), findsNothing);
  expect(
    tester
        .widget<TextFormField>(find.byKey(const Key('login_email_field')))
        .controller!
        .text,
    isEmpty,
  );
  expect(
    tester
        .widget<TextFormField>(find.byKey(const Key('login_password_field')))
        .controller!
        .text,
    isEmpty,
  );
}

Future<void> _login(WidgetTester tester, String email, String password) async {
  await tester.ensureVisible(find.byKey(const Key('login_email_field')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('login_email_field')),
    email,
  );
  await tester.ensureVisible(find.byKey(const Key('login_password_field')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    password,
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();
}

Future<void> _logout(WidgetTester tester) async {
  if (find.byType(NavigationBar).evaluate().isNotEmpty) {
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
  }
  final logout = find.text('LOG OUT').first;
  await tester.ensureVisible(logout);
  await tester.tap(logout);
  await tester.pumpAndSettle();
  expect(find.text('GET STARTED'), findsOneWidget);
}
