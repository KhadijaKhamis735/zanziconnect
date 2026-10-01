import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanzi_connect/models/provider_workspace_data.dart';
import 'package:zanzi_connect/models/registered_account.dart';
import 'package:zanzi_connect/screens/provider_workspace_screen.dart';

void main() {
  testWidgets('wide provider layout keeps all five tabs in bottom navigation',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final account = RegisteredAccount(
      id: 'provider-wide-navigation',
      fullName: 'Wide Provider',
      email: 'wide@test.example',
      phone: '4',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.getBottomRight(find.byType(NavigationBar)).dy, 900);
    expect(find.text('Provider Dashboard'), findsOneWidget);
    expect(find.text('Welcome back, Wide'), findsOneWidget);
    expect(find.text('0 of 5 requirements complete'), findsOneWidget);
    expect(find.text('Complete your provider profile'), findsOneWidget);
    expect(find.text('COMPLETE PROFILE'), findsOneWidget);
    expect(find.text('MANAGE PROFILE'), findsOneWidget);
    expect(find.text('PROFILE SETUP REQUIRED'), findsOneWidget);
    expect(find.text('ADD EXPERIENCE'), findsOneWidget);
    expect(find.text('VIEW BOOKINGS'), findsOneWidget);
    final recentActivity =
        find.byKey(const Key('provider_dashboard_recent_activity'));
    await tester.ensureVisible(recentActivity);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(recentActivity).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy));

    const expectedHeadings = [
      'Experiences',
      'Bookings',
      'Settlements',
      'Provider Profile',
    ];
    for (var index = 1; index < 5; index++) {
      await tester.tap(find.byKey(Key('provider_navigation_$index')));
      await tester.pumpAndSettle();
      expect(find.text(expectedHeadings[index - 1]), findsAtLeastNWidgets(1));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        index,
      );
      expect(tester.getBottomRight(find.byType(NavigationBar)).dy, 900);
    }
  });

  testWidgets('dashboard summary cards open their existing workspace tabs',
      (tester) async {
    final account = RegisteredAccount(
      id: 'provider-dashboard-card-navigation',
      fullName: 'Navigation Provider',
      email: 'navigation@test.example',
      phone: '4',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));

    final experiencesCard =
        find.byKey(const Key('provider_dashboard_summary_experiences'));
    await tester.ensureVisible(experiencesCard);
    await tester.tap(experiencesCard);
    await tester.pumpAndSettle();
    expect(find.text('Experiences'), findsAtLeastNWidgets(1));

    await tester.tap(find.byKey(const Key('provider_navigation_0')));
    await tester.pumpAndSettle();
    await tester.tap(
        find.byKey(const Key('provider_dashboard_summary_upcoming_bookings')));
    await tester.pumpAndSettle();
    expect(find.text('Bookings'), findsAtLeastNWidgets(1));

    await tester.tap(find.byKey(const Key('provider_navigation_0')));
    await tester.pumpAndSettle();
    await tester.tap(
        find.byKey(const Key('provider_dashboard_summary_completed_bookings')));
    await tester.pumpAndSettle();
    expect(find.text('Bookings'), findsAtLeastNWidgets(1));

    await tester.tap(find.byKey(const Key('provider_navigation_0')));
    await tester.pumpAndSettle();
    await tester.tap(
        find.byKey(const Key('provider_dashboard_summary_pending_settlement')));
    await tester.pumpAndSettle();
    expect(find.text('Settlements'), findsAtLeastNWidgets(1));
  });

  testWidgets(
      'settlements empty state fits desktop and mobile and opens bookings',
      (tester) async {
    final account = RegisteredAccount(
      id: 'provider-settlement-empty-state',
      fullName: 'Settlement Provider',
      email: 'settlement@test.example',
      phone: '9',
      role: AccountRole.provider,
    );

    for (final size in [const Size(1440, 900), const Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(MaterialApp(
        home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
      ));
      await tester.tap(find.byKey(const Key('provider_navigation_3')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Track settlement status for your completed ZanziConnect experiences.'),
          findsOneWidget);
      expect(find.text('NO SETTLEMENTS YET'), findsOneWidget);
      expect(find.text('VIEW BOOKINGS →'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);

      final lastStep = find.text('4. Settlement record');
      await tester.ensureVisible(lastStep);
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(lastStep).dy,
          lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy));

      await tester.ensureVisible(find.text('VIEW BOOKINGS →'));
      await tester.tap(find.text('VIEW BOOKINGS →'));
      await tester.pumpAndSettle();
      expect(find.text('Bookings'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('complete profile actions open the existing profile editor',
      (tester) async {
    final account = RegisteredAccount(
      id: 'provider-dashboard-profile-action',
      fullName: 'Profile Provider',
      email: 'profile@test.example',
      phone: '6',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));
    final completeProfile = find.text('COMPLETE PROFILE').first;
    await tester.ensureVisible(completeProfile);
    await tester.tap(completeProfile);
    await tester.pumpAndSettle();
    expect(find.text('Provider Profile'), findsOneWidget);
    expect(find.text('SAVE PROFILE'), findsOneWidget);
  });

  testWidgets('mobile dashboard keeps actions and bottom navigation usable',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final account = RegisteredAccount(
      id: 'provider-mobile-dashboard',
      fullName: 'Mobile Provider',
      email: 'mobile@test.example',
      phone: '5',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byTooltip('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final recentActivity =
        find.byKey(const Key('provider_dashboard_recent_activity'));
    await tester.ensureVisible(recentActivity);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(recentActivity).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
        find.byKey(const Key('provider_dashboard_summary_experiences')));
    await tester
        .tap(find.byKey(const Key('provider_dashboard_summary_experiences')));
    await tester.pumpAndSettle();
    expect(find.text('Experiences'), findsAtLeastNWidgets(1));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile Experiences empty state and add action fit the viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final account = RegisteredAccount(
      id: 'provider-mobile-experiences',
      fullName: 'Mobile Experiences Provider',
      email: 'experiences-mobile@test.example',
      phone: '7',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));
    await tester.tap(find.byKey(const Key('provider_navigation_1')));
    await tester.pumpAndSettle();

    expect(find.text('Experiences'), findsAtLeastNWidgets(1));
    expect(find.text('NO EXPERIENCES YET'), findsOneWidget);
    final lastHowItWorksStep = find.text('Receive bookings');
    await tester.ensureVisible(lastHowItWorksStep);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(lastHowItWorksStep).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy));
    expect(tester.takeException(), isNull);

    final addFirst = find.text('ADD YOUR FIRST EXPERIENCE');
    await tester.ensureVisible(addFirst);
    await tester.tap(addFirst);
    await tester.pumpAndSettle();
    expect(find.text('Add Experience'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'experience card reflects current eligibility on phone and desktop',
      (tester) async {
    final account = RegisteredAccount(
      id: 'provider-experience-card-responsive',
      fullName: 'Card Provider',
      email: 'card@test.example',
      phone: '8',
      role: AccountRole.provider,
    );
    final workspace = ProviderWorkspaceData.forAccount(account);
    workspace.experiences.add(ProviderExperienceData(
      id: 'card-experience',
      title: 'Coastal Walk',
      description: 'A guided coast walk.',
      location: 'Nungwi, Zanzibar',
      price: 45000,
      capacity: 5,
      includes: 'Local guide',
      cancellationPolicy: 'Free until one day before',
      category: 'Tours',
    ));

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));
    await tester.tap(find.byKey(const Key('provider_navigation_1')));
    await tester.pumpAndSettle();

    final card =
        find.byKey(const Key('provider_experience_card_card-experience'));
    expect(find.text('Coastal Walk'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('ACTION REQUIRED'), findsOneWidget);
    expect(find.text('Complete your provider profile.'), findsOneWidget);
    expect(tester.getSize(card).width, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1440, 1000);
    await tester.pumpAndSettle();
    expect(tester.getSize(card).width, lessThan(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Bookings empty state filters, searches, and links to Experiences',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final account = RegisteredAccount(
      id: 'provider-empty-bookings',
      fullName: 'Bookings Provider',
      email: 'bookings@test.example',
      phone: '9',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));
    await tester.tap(find.byKey(const Key('provider_navigation_2')));
    await tester.pumpAndSettle();

    expect(find.text('NO BOOKINGS YET'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('TOTAL BOOKINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester
        .tap(find.byKey(const Key('provider_bookings_filter_completed')));
    await tester.pumpAndSettle();
    expect(find.text('No completed bookings'), findsOneWidget);

    final search = find.byType(TextField);
    await tester.enterText(search, 'ZB-001');
    await tester.pumpAndSettle();
    expect(find.text('No bookings found'), findsOneWidget);
    await tester.enterText(search, '');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('provider_bookings_filter_all')));
    await tester.pumpAndSettle();
    final experiencesAction = find.text('VIEW MY EXPERIENCES');
    await tester.ensureVisible(experiencesAction);
    await tester.tap(experiencesAction);
    await tester.pumpAndSettle();
    expect(find.text('NO EXPERIENCES YET'), findsOneWidget);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'provider starts with an empty account-scoped workspace and can add an experience',
      (tester) async {
    final account = RegisteredAccount(
      id: 'provider-test-${DateTime.now().microsecondsSinceEpoch}',
      fullName: 'Test Provider',
      email: 'provider@test.example',
      phone: '+255700000000',
      role: AccountRole.provider,
    );
    await tester.pumpWidget(MaterialApp(
      home: ProviderWorkspaceScreen(account: account, onLogout: () {}),
    ));

    expect(find.text('PROFILE SETUP REQUIRED'), findsOneWidget);
    expect(find.text('NO EXPERIENCES YET'), findsNothing);
    await tester.tap(find.byKey(const Key('provider_navigation_1')));
    await tester.pumpAndSettle();
    expect(find.text('NO EXPERIENCES YET'), findsOneWidget);
    final addFirst = find.text('ADD YOUR FIRST EXPERIENCE');
    await tester.ensureVisible(addFirst);
    await tester.tap(addFirst);
    await tester.pumpAndSettle();

    await _enter(tester, 'Experience Title', 'Stone Town Walk');
    await _enter(tester, 'Description', 'A guided heritage walk.');
    await _enter(tester, 'Location', 'Stone Town');
    await _enter(tester, 'Price (TZS)', '30000');
    await _enter(tester, 'Default Guests / Capacity', '6');
    await _enter(tester, "What's Included", 'Local guide');
    await _enter(tester, 'Cancellation Policy', 'Free until one day before');
    await tester.tap(find.text('SAVE EXPERIENCE'));
    await tester.pumpAndSettle();

    expect(find.text('Stone Town Walk'), findsAtLeastNWidgets(1));
    expect(find.text('Marine · Stone Town'), findsOneWidget);
    expect(find.text('ACTION REQUIRED'), findsOneWidget);
    expect(find.text('Booking readiness · 0 of 5 checks complete'),
        findsOneWidget);
    expect(ProviderWorkspaceData.forAccount(account).experiences, hasLength(1));

    final requirementsAction = find.text('MANAGE REQUIREMENTS').first;
    await tester.ensureVisible(requirementsAction);
    await tester.tap(requirementsAction);
    await tester.pumpAndSettle();
    expect(find.text('Booking Requirements'), findsOneWidget);
    expect(
        find.text('Complete your provider profile.'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    final editAction = find.text('EDIT').first;
    await tester.ensureVisible(editAction);
    await tester.tap(editAction);
    await tester.pumpAndSettle();
    expect(find.text('Edit Experience'), findsOneWidget);
    expect(find.text('Stone Town Walk'), findsAtLeastNWidgets(1));
  });

  test('each registered provider receives separate prototype data', () {
    final first = RegisteredAccount(
      id: 'provider-isolation-a',
      fullName: 'Provider A',
      email: 'a@test.example',
      phone: '1',
      role: AccountRole.provider,
    );
    final second = RegisteredAccount(
      id: 'provider-isolation-b',
      fullName: 'Provider B',
      email: 'b@test.example',
      phone: '2',
      role: AccountRole.provider,
    );
    ProviderWorkspaceData.forAccount(first).experiences.add(
          ProviderExperienceData(
            id: 'own',
            title: 'Provider A experience',
            description: '',
            location: '',
            price: 1,
            capacity: 1,
            includes: '',
            cancellationPolicy: '',
            category: 'Tours',
          ),
        );

    expect(ProviderWorkspaceData.forAccount(first).experiences, hasLength(1));
    expect(ProviderWorkspaceData.forAccount(second).experiences, isEmpty);
  });

  test('booking eligibility requires every provider requirement', () {
    final profile = ProviderWorkspaceData.forAccount(RegisteredAccount(
      id: 'provider-requirement-check',
      fullName: 'Requirements',
      email: 'requirements@test.example',
      phone: '3',
      role: AccountRole.provider,
    )).profile;
    profile
      ..businessName = 'Coastal Walks'
      ..active = true
      ..recordValid = true
      ..documentsValid = true
      ..documentExpiry = DateTime.now().add(const Duration(days: 10))
      ..capacity = 4
      ..departureChecksComplete = true;
    expect(profile.status, 'BOOKING ELIGIBLE');

    profile.documentExpiry = DateTime.now().subtract(const Duration(days: 1));
    expect(profile.bookingEligible, isFalse);
    expect(profile.documentStatus, 'EXPIRED');
    expect(profile.status, 'BOOKING UNAVAILABLE');
  });
}

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = find.byKey(Key('provider_field_$label'));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
}
