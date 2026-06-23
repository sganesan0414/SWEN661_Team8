import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:careconnect/main.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'mocks.dart';

// Boots the real app entry point (MyApp) instead of pumping a screen in
// isolation, so this test exercises the actual cross-screen navigation
// wiring: LoginScreen -> DashboardScreen -> pushed sub-screen -> back,
// across every bottom-nav tab, and back to LoginScreen on sign out.
void main() {
  setUpAll(registerFallbacks);

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

    // Sign in (mock signIn() always succeeds after a 1.5s delay).
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
    await tester.tap(find.byTooltip('Settings'));
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
