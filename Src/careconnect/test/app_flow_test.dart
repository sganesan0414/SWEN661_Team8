import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careconnect/main.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'mocks.dart';

// Boots the real app entry point (MyApp) instead of pumping a screen in
// isolation, so this test exercises the actual cross-screen navigation
// wiring: LoginScreen -> DashboardScreen -> pushed sub-screen -> back,
// across every bottom-nav tab, and back to LoginScreen on sign out.
void main() {
  setUpAll(registerFallbacks);

  setUp(() {
    // signIn() now validates against accounts persisted via SharedPreferences
    // (account_provider.dart), so each test registers its own account first
    // instead of relying on an always-succeeds mock.
    SharedPreferences.setMockInitialValues({});
  });

  Widget appUnderTest() {
    final mockNotif = MockNotificationService();
    when(() => mockNotif.scheduleAppointmentReminder(any())).thenAnswer((_) async {});
    when(() => mockNotif.cancelAppointmentReminders(any())).thenAnswer((_) async {});
    return ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(mockNotif)],
      child: const MyApp(),
    );
  }

  testWidgets('sign in, push/pop a screen, visit every tab, sign out', (tester) async {
    await tester.pumpWidget(appUnderTest());

    // Starts on LoginScreen.
    expect(find.text('Welcome Back'), findsOneWidget);

    // Register an account first: signIn() validates against accounts
    // persisted via SharedPreferences, so there's nothing to sign into yet.
    final createAccountLink = find.text('Create Account');
    await tester.ensureVisible(createAccountLink);
    await tester.tap(createAccountLink);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Siva');
    await tester.enterText(find.byType(TextFormField).at(1), 'siva@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '555-123-4567');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    final agreeCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(agreeCheckbox);
    await tester.tap(agreeCheckbox);
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // register() completes + navigates
    await tester.pump(const Duration(seconds: 3)); // "Account created" SnackBar dismisses
    expect(find.text('Welcome Back'), findsOneWidget); // back on LoginScreen

    // Sign in with the account just registered.
    await tester.enterText(find.byType(TextFormField).first, 'siva@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Lands on DashboardScreen, Home tab.
    expect(find.text('CareConnect'), findsOneWidget);
    expect(find.textContaining('Good Morning, Siva'), findsOneWidget);

    // Push a sub-screen via a Quick Action, then navigate back.
    await tester.ensureVisible(find.text('Health\nMetrics'));
    await tester.tap(find.text('Health\nMetrics'));
    await tester.pumpAndSettle();
    expect(find.text('Health Metrics'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('CareConnect'), findsOneWidget);

    // Dashboard -> Profile (tap the greeting), then navigate back.
    final greeting = find.text('Good Morning, Siva');
    await tester.ensureVisible(greeting);
    await tester.tap(greeting);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('CareConnect'), findsOneWidget);

    // Dashboard -> Settings (accessibility preferences), then navigate back.
    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Manage your accessibility preferences'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('CareConnect'), findsOneWidget);

    // Dashboard -> Pharmacy (Quick Action tile), then navigate back.
    final pharmacyTile = find.text('Pharmacy');
    await tester.ensureVisible(pharmacyTile);
    await tester.tap(pharmacyTile);
    await tester.pumpAndSettle();
    expect(find.text('My Pharmacies'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('CareConnect'), findsOneWidget);

    // Walk every bottom-nav tab. Assert on the ContextBar label since it's
    // unique on screen (AppBar title and bottom-nav label share text for
    // Appointments/Reminders/Care Team, which would make find.text ambiguous).
    const tabs = {
      'Medications': 'Home › My Medications',
      'Appointments': 'Home › Appointments',
      'Reminders': 'Home › Reminders',
      'Care Team': 'Home › Care Team',
      'Home': 'Home - Daily Overview',
    };
    for (final entry in tabs.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
    }

    // Sign out returns to LoginScreen.
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
