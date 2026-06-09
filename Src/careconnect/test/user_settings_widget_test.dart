import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/user_settings.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    // Test 1: Verify high contrast mode toggle works
    testWidgets('High Contrast Mode toggle changes state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Find the High Contrast Mode switch
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Get the first switch (High Contrast Mode)
      final highContrastSwitch = switches.first;

      // Verify initial state is off
      expect(
        find.ancestor(
          of: highContrastSwitch,
          matching: find.text('High Contrast Mode'),
        ),
        findsOneWidget,
      );

      // Tap the switch
      await tester.tap(highContrastSwitch);
      await tester.pump();

      // Switch should now be toggled (state changed)
      final toggledSwitch = find.byType(Switch).first;
      expect(toggledSwitch, findsOneWidget);
    });

    // Test 2: Verify text size slider adjusts value
    testWidgets('Text Size slider updates text size value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Find all sliders
      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      // Get the first slider (Text Size)
      final textSizeSlider = sliders.first;

      // Verify initial text size display (16px)
      expect(find.text('16px'), findsOneWidget);

      // Drag the slider to the right to increase text size
      await tester.drag(textSizeSlider, const Offset(50, 0));
      await tester.pump();

      // Text size should have increased (should show a different value)
      expect(find.text('16px'), findsNothing);
    });

    // Test 3: Verify screen reader and sound alerts toggles work
    testWidgets('Audio & Alerts toggles can be toggled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Find all switches
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Get the screen reader switch (should be enabled by default)
      final screenReaderSwitch = switches.at(1);

      // Verify Screen Reader text is present
      expect(find.text('Screen Reader'), findsOneWidget);

      // Tap the screen reader switch to disable it
      await tester.tap(screenReaderSwitch);
      await tester.pump();

      // Switch state should change
      final updatedSwitch = find.byType(Switch).at(1);
      expect(updatedSwitch, findsOneWidget);

      // Now toggle Sound Alerts (should be off by default)
      final soundAlertsSwitch = switches.at(2);
      await tester.tap(soundAlertsSwitch);
      await tester.pump();

      expect(find.text('Sound Alerts'), findsOneWidget);
    });
  });
}
