import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/care_team_screen.dart';
import 'package:careconnect/theme/app_theme.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: AppTheme.theme, home: Scaffold(body: child)),
    );

void main() {
  group('CareTeamScreen', () {
    testWidgets('renders member list', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
      expect(find.text('Patricia Williams'), findsOneWidget);
      expect(find.text('Dr. Michael Chen'), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('Emergency Contacts'), findsOneWidget);
    });

    testWidgets('shows emergency badge on emergency contact', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      expect(find.text('Emergency'), findsOneWidget);
    });
  });
}
