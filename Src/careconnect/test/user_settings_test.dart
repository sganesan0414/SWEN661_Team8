import 'package:flutter_test/flutter_test.dart';

// Data model for accessibility settings
class AccessibilitySettings {
  final bool highContrastMode;
  final double textSize;
  final double contrastLevel;
  final bool screenMagnification;
  final bool screenReader;
  final bool soundAlerts;

  const AccessibilitySettings({
    this.highContrastMode = false,
    this.textSize = 16,
    this.contrastLevel = 100,
    this.screenMagnification = false,
    this.screenReader = true,
    this.soundAlerts = false,
  });

  AccessibilitySettings copyWith({
    bool? highContrastMode,
    double? textSize,
    double? contrastLevel,
    bool? screenMagnification,
    bool? screenReader,
    bool? soundAlerts,
  }) {
    return AccessibilitySettings(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      textSize: textSize ?? this.textSize,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      screenMagnification: screenMagnification ?? this.screenMagnification,
      screenReader: screenReader ?? this.screenReader,
      soundAlerts: soundAlerts ?? this.soundAlerts,
    );
  }

  bool isEqual(AccessibilitySettings other) {
    return highContrastMode == other.highContrastMode &&
        textSize == other.textSize &&
        contrastLevel == other.contrastLevel &&
        screenMagnification == other.screenMagnification &&
        screenReader == other.screenReader &&
        soundAlerts == other.soundAlerts;
  }
}

// Utility class for settings validation and calculations
class SettingsValidator {
  static const double minTextSize = 12;
  static const double maxTextSize = 24;
  static const double minContrastLevel = 50;
  static const double maxContrastLevel = 100;

  static bool isValidTextSize(double size) {
    return size >= minTextSize && size <= maxTextSize;
  }

  static bool isValidContrastLevel(double level) {
    return level >= minContrastLevel && level <= maxContrastLevel;
  }

  static double clampTextSize(double size) {
    return size.clamp(minTextSize, maxTextSize);
  }

  static double clampContrastLevel(double level) {
    return level.clamp(minContrastLevel, maxContrastLevel);
  }
}

// Utility class for text size calculations
class TextSizeCalculator {
  static double getScaleFactor(double textSize) {
    const defaultSize = 16;
    return textSize / defaultSize;
  }

  static double getScaledSize(double baseSize, double textSize) {
    final scaleFactor = getScaleFactor(textSize);
    return baseSize * scaleFactor;
  }

  static String formatTextSizeDisplay(double size) {
    return '${size.toInt()}px';
  }

  static String formatContrastDisplay(double contrast) {
    return '${contrast.toInt()}%';
  }
}

// Utility class for contrast calculations
class ContrastCalculator {
  static bool shouldApplyHighContrast(bool highContrastMode, double contrastLevel) {
    return highContrastMode || contrastLevel > 75;
  }

  static double getEffectiveContrast(bool highContrastMode, double contrastLevel) {
    if (highContrastMode) {
      return 100;
    }
    return contrastLevel;
  }

  static String getAccessibilityLevel(double contrastLevel) {
    if (contrastLevel >= 100) {
      return 'Maximum';
    } else if (contrastLevel >= 75) {
      return 'High';
    } else if (contrastLevel >= 50) {
      return 'Standard';
    }
    return 'Low';
  }
}

void main() {
  group('AccessibilitySettings Data Model Tests', () {
    test('default constructor initializes with correct defaults', () {
      final settings = const AccessibilitySettings();

      expect(settings.highContrastMode, false);
      expect(settings.textSize, 16);
      expect(settings.contrastLevel, 100);
      expect(settings.screenMagnification, false);
      expect(settings.screenReader, true);
      expect(settings.soundAlerts, false);
    });

    test('custom constructor initializes with provided values', () {
      final settings = const AccessibilitySettings(
        highContrastMode: true,
        textSize: 20,
        contrastLevel: 75,
        screenMagnification: true,
        screenReader: false,
        soundAlerts: true,
      );

      expect(settings.highContrastMode, true);
      expect(settings.textSize, 20);
      expect(settings.contrastLevel, 75);
      expect(settings.screenMagnification, true);
      expect(settings.screenReader, false);
      expect(settings.soundAlerts, true);
    });

    test('copyWith updates single field', () {
      final settings = const AccessibilitySettings();
      final updated = settings.copyWith(highContrastMode: true);

      expect(updated.highContrastMode, true);
      expect(updated.textSize, 16);
      expect(updated.contrastLevel, 100);
    });

    test('copyWith preserves original object', () {
      final settings = const AccessibilitySettings();
      final updated = settings.copyWith(textSize: 20);

      expect(settings.textSize, 16);
      expect(updated.textSize, 20);
    });

    test('copyWith can update multiple fields', () {
      final settings = const AccessibilitySettings();
      final updated = settings.copyWith(
        highContrastMode: true,
        textSize: 20,
        screenReader: false,
      );

      expect(updated.highContrastMode, true);
      expect(updated.textSize, 20);
      expect(updated.screenReader, false);
      expect(updated.contrastLevel, 100);
    });

    test('isEqual returns true for identical settings', () {
      final settings1 = const AccessibilitySettings(
        highContrastMode: true,
        textSize: 18,
      );
      final settings2 = const AccessibilitySettings(
        highContrastMode: true,
        textSize: 18,
      );

      expect(settings1.isEqual(settings2), true);
    });

    test('isEqual returns false for different settings', () {
      final settings1 = const AccessibilitySettings(
        highContrastMode: true,
        textSize: 18,
      );
      final settings2 = const AccessibilitySettings(
        highContrastMode: false,
        textSize: 16,
      );

      expect(settings1.isEqual(settings2), false);
    });

    test('isEqual detects single field difference', () {
      final settings1 = const AccessibilitySettings();
      final settings2 = settings1.copyWith(screenReader: false);

      expect(settings1.isEqual(settings2), false);
    });
  });

  group('SettingsValidator Tests', () {
    test('valid text size passes validation', () {
      expect(SettingsValidator.isValidTextSize(16), true);
    });

    test('minimum text size is valid', () {
      expect(SettingsValidator.isValidTextSize(12), true);
    });

    test('maximum text size is valid', () {
      expect(SettingsValidator.isValidTextSize(24), true);
    });

    test('text size below minimum fails validation', () {
      expect(SettingsValidator.isValidTextSize(11), false);
    });

    test('text size above maximum fails validation', () {
      expect(SettingsValidator.isValidTextSize(25), false);
    });

    test('valid contrast level passes validation', () {
      expect(SettingsValidator.isValidContrastLevel(75), true);
    });

    test('minimum contrast level is valid', () {
      expect(SettingsValidator.isValidContrastLevel(50), true);
    });

    test('maximum contrast level is valid', () {
      expect(SettingsValidator.isValidContrastLevel(100), true);
    });

    test('contrast level below minimum fails validation', () {
      expect(SettingsValidator.isValidContrastLevel(49), false);
    });

    test('contrast level above maximum fails validation', () {
      expect(SettingsValidator.isValidContrastLevel(101), false);
    });

    test('clampTextSize returns same value when in range', () {
      expect(SettingsValidator.clampTextSize(16), 16);
    });

    test('clampTextSize clamps to minimum', () {
      expect(SettingsValidator.clampTextSize(5), 12);
    });

    test('clampTextSize clamps to maximum', () {
      expect(SettingsValidator.clampTextSize(30), 24);
    });

    test('clampContrastLevel returns same value when in range', () {
      expect(SettingsValidator.clampContrastLevel(75), 75);
    });

    test('clampContrastLevel clamps to minimum', () {
      expect(SettingsValidator.clampContrastLevel(25), 50);
    });

    test('clampContrastLevel clamps to maximum', () {
      expect(SettingsValidator.clampContrastLevel(150), 100);
    });
  });

  group('TextSizeCalculator Tests', () {
    test('getScaleFactor returns 1.0 for default size', () {
      final factor = TextSizeCalculator.getScaleFactor(16);
      expect(factor, 1.0);
    });

    test('getScaleFactor returns 1.25 for size 20', () {
      final factor = TextSizeCalculator.getScaleFactor(20);
      expect(factor, closeTo(1.25, 0.01));
    });

    test('getScaleFactor returns 0.75 for size 12', () {
      final factor = TextSizeCalculator.getScaleFactor(12);
      expect(factor, closeTo(0.75, 0.01));
    });

    test('getScaledSize calculates correct scaled value', () {
      final scaled = TextSizeCalculator.getScaledSize(16, 20);
      expect(scaled, closeTo(20, 0.1));
    });

    test('getScaledSize with default text size returns base size', () {
      final scaled = TextSizeCalculator.getScaledSize(14, 16);
      expect(scaled, 14);
    });

    test('getScaledSize scales down correctly', () {
      final scaled = TextSizeCalculator.getScaledSize(20, 12);
      expect(scaled, closeTo(15, 0.1));
    });

    test('formatTextSizeDisplay formats correctly', () {
      expect(TextSizeCalculator.formatTextSizeDisplay(16), '16px');
      expect(TextSizeCalculator.formatTextSizeDisplay(20.5), '20px');
    });

    test('formatContrastDisplay formats correctly', () {
      expect(TextSizeCalculator.formatContrastDisplay(100), '100%');
      expect(TextSizeCalculator.formatContrastDisplay(75.5), '75%');
    });
  });

  group('ContrastCalculator Tests', () {
    test('high contrast mode true triggers contrast application', () {
      expect(
        ContrastCalculator.shouldApplyHighContrast(true, 50),
        true,
      );
    });

    test('high contrast mode false with low contrast does not trigger', () {
      expect(
        ContrastCalculator.shouldApplyHighContrast(false, 50),
        false,
      );
    });

    test('high contrast mode false with high contrast triggers', () {
      expect(
        ContrastCalculator.shouldApplyHighContrast(false, 80),
        true,
      );
    });

    test('getEffectiveContrast returns 100 when high contrast enabled', () {
      final contrast = ContrastCalculator.getEffectiveContrast(true, 50);
      expect(contrast, 100);
    });

    test('getEffectiveContrast returns contrast level when high contrast disabled', () {
      final contrast = ContrastCalculator.getEffectiveContrast(false, 75);
      expect(contrast, 75);
    });

    test('getAccessibilityLevel returns Maximum for 100', () {
      expect(ContrastCalculator.getAccessibilityLevel(100), 'Maximum');
    });

    test('getAccessibilityLevel returns High for 75-99', () {
      expect(ContrastCalculator.getAccessibilityLevel(75), 'High');
      expect(ContrastCalculator.getAccessibilityLevel(90), 'High');
    });

    test('getAccessibilityLevel returns Standard for 50-74', () {
      expect(ContrastCalculator.getAccessibilityLevel(50), 'Standard');
      expect(ContrastCalculator.getAccessibilityLevel(70), 'Standard');
    });

    test('getAccessibilityLevel returns Low for below 50', () {
      expect(ContrastCalculator.getAccessibilityLevel(40), 'Low');
    });
  });

  group('Settings State Management Tests', () {
    test('initial settings match defaults', () {
      final settings1 = const AccessibilitySettings();
      final settings2 = const AccessibilitySettings();

      expect(settings1.isEqual(settings2), true);
    });

    test('toggling high contrast mode updates state', () {
      final initial = const AccessibilitySettings(highContrastMode: false);
      final toggled = initial.copyWith(highContrastMode: true);

      expect(initial.highContrastMode, false);
      expect(toggled.highContrastMode, true);
    });

    test('adjusting text size updates state', () {
      final initial = const AccessibilitySettings(textSize: 16);
      final adjusted = initial.copyWith(textSize: 20);

      expect(initial.textSize, 16);
      expect(adjusted.textSize, 20);
    });

    test('multiple setting changes are tracked', () {
      final initial = const AccessibilitySettings();
      var current = initial;

      current = current.copyWith(highContrastMode: true);
      current = current.copyWith(textSize: 20);
      current = current.copyWith(screenReader: false);
      current = current.copyWith(soundAlerts: true);

      expect(current.highContrastMode, true);
      expect(current.textSize, 20);
      expect(current.screenReader, false);
      expect(current.soundAlerts, true);
    });

    test('reverting changes returns to initial state', () {
      final initial = const AccessibilitySettings();
      var current = initial;

      current = current.copyWith(highContrastMode: true);
      current = current.copyWith(textSize: 22);
      current = const AccessibilitySettings();

      expect(current.isEqual(initial), true);
    });
  });

  group('Visual Settings Validation Tests', () {
    test('text size within range is valid', () {
      expect(SettingsValidator.isValidTextSize(14), true);
      expect(SettingsValidator.isValidTextSize(18), true);
      expect(SettingsValidator.isValidTextSize(22), true);
    });

    test('contrast level within range is valid', () {
      expect(SettingsValidator.isValidContrastLevel(60), true);
      expect(SettingsValidator.isValidContrastLevel(80), true);
      expect(SettingsValidator.isValidContrastLevel(95), true);
    });

    test('text size and contrast can be configured together', () {
      final settings = const AccessibilitySettings(
        textSize: 20,
        contrastLevel: 80,
      );

      expect(SettingsValidator.isValidTextSize(settings.textSize), true);
      expect(SettingsValidator.isValidContrastLevel(settings.contrastLevel), true);
    });
  });
}
