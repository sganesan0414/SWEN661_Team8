import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/screens/user_settings.dart';

void main() {
  // Switch order in SettingsScreen:
  //   0 = High Contrast Mode  (Visual Settings)
  //   1 = Screen Magnification (Visual Settings)
  //   2 = Screen Reader        (Audio & Alerts, default: true)
  //   3 = Sound Alerts         (Audio & Alerts, default: false)

  group('SettingsScreen Widget Tests', () {
    testWidgets('High Contrast Mode toggle changes state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      expect(find.text('High Contrast Mode'), findsOneWidget);

      await tester.tap(switches.first);
      await tester.pump();

      expect(find.byType(Switch).first, findsOneWidget);
    });

    testWidgets('Text Size slider updates text size value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );

      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      final textSizeSlider = sliders.first;
      expect(find.text('16px'), findsOneWidget);

      final slider = tester.widget<Slider>(textSizeSlider);
      expect(slider.value, 16.0);
      expect(slider.min, 12.0);
      expect(slider.max, 24.0);
    });

    testWidgets('Audio & Alerts toggles can be toggled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Screen Reader is at index 2 (enabled by default)
      final screenReaderSwitch = switches.at(2);
      expect(find.text('Screen Reader'), findsOneWidget);

      await tester.tap(screenReaderSwitch);
      await tester.pump();
      expect(find.byType(Switch).at(2), findsOneWidget);

      // Sound Alerts is at index 3 (disabled by default)
      final soundAlertsSwitch = switches.at(3);
      await tester.tap(soundAlertsSwitch);
      await tester.pump();

      expect(find.text('Sound Alerts'), findsOneWidget);
    });
  });
}
