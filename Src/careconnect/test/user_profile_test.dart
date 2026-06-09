import 'package:flutter_test/flutter_test.dart';

// Utility class for password validation
class PasswordValidator {
  static const int minLength = 8;

  static bool isValidLength(String password) {
    return password.length >= minLength;
  }

  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static String? validatePassword(String password, String confirmPassword) {
    if (!isValidLength(password)) {
      return 'Password must be at least $minLength characters';
    }
    if (!doPasswordsMatch(password, confirmPassword)) {
      return 'Passwords do not match';
    }
    return null;
  }
}

// Data model for user profile
class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String careNotes;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.careNotes,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? careNotes,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      careNotes: careNotes ?? this.careNotes,
    );
  }

  bool isEqual(UserProfile other) {
    return fullName == other.fullName &&
        email == other.email &&
        phone == other.phone &&
        role == other.role &&
        careNotes == other.careNotes;
  }
}

// Utility class for profile validation
class ProfileValidator {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?1?\s?(\(?\d{3}\)?[\s.-]?)?\d{3}[\s.-]?\d{4}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isNotEmpty(String value) {
    return value.isNotEmpty && value.trim().isNotEmpty;
  }

  static String? validateFullName(String name) {
    if (!isNotEmpty(name)) {
      return 'Full name cannot be empty';
    }
    if (name.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (!isNotEmpty(email)) {
      return 'Email cannot be empty';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String phone) {
    if (!isNotEmpty(phone)) {
      return 'Phone number cannot be empty';
    }
    if (!isValidPhone(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}

void main() {
  group('PasswordValidator Tests', () {
    test('valid password returns true for length check', () {
      expect(PasswordValidator.isValidLength('password123'), true);
    });

    test('short password returns false for length check', () {
      expect(PasswordValidator.isValidLength('pass123'), false);
    });

    test('password exactly 8 characters is valid', () {
      expect(PasswordValidator.isValidLength('12345678'), true);
    });

    test('matching passwords return true', () {
      expect(PasswordValidator.doPasswordsMatch('password123', 'password123'), true);
    });

    test('non-matching passwords return false', () {
      expect(PasswordValidator.doPasswordsMatch('password123', 'password456'), false);
    });

    test('validatePassword returns null for valid inputs', () {
      final result = PasswordValidator.validatePassword('password123', 'password123');
      expect(result, null);
    });

    test('validatePassword returns error for short password', () {
      final result = PasswordValidator.validatePassword('pass123', 'pass123');
      expect(result, isNotNull);
      expect(result, contains('at least'));
    });

    test('validatePassword returns error for mismatched passwords', () {
      final result = PasswordValidator.validatePassword('password123', 'password456');
      expect(result, isNotNull);
      expect(result, contains('do not match'));
    });

    test('empty passwords fail validation', () {
      final result = PasswordValidator.validatePassword('', '');
      expect(result, isNotNull);
    });
  });

  group('ProfileValidator Tests', () {
    test('valid email passes validation', () {
      expect(ProfileValidator.isValidEmail('john.smith@example.com'), true);
    });

    test('invalid email fails validation', () {
      expect(ProfileValidator.isValidEmail('invalid.email'), false);
    });

    test('email without domain fails validation', () {
      expect(ProfileValidator.isValidEmail('john@'), false);
    });

    test('valid phone passes validation', () {
      expect(ProfileValidator.isValidPhone('+1 (555) 123-4567'), true);
    });

    test('phone with dashes passes validation', () {
      expect(ProfileValidator.isValidPhone('555-123-4567'), true);
    });

    test('invalid phone format fails validation', () {
      expect(ProfileValidator.isValidPhone('123'), false);
    });

    test('empty string fails not empty check', () {
      expect(ProfileValidator.isNotEmpty(''), false);
    });

    test('whitespace only fails not empty check', () {
      expect(ProfileValidator.isNotEmpty('   '), false);
    });

    test('valid full name passes validation', () {
      final result = ProfileValidator.validateFullName('John Smith');
      expect(result, null);
    });

    test('empty full name fails validation', () {
      final result = ProfileValidator.validateFullName('');
      expect(result, isNotNull);
    });

    test('single character full name fails validation', () {
      final result = ProfileValidator.validateFullName('J');
      expect(result, isNotNull);
    });

    test('valid email passes email validation', () {
      final result = ProfileValidator.validateEmail('john.smith@example.com');
      expect(result, null);
    });

    test('invalid email fails email validation', () {
      final result = ProfileValidator.validateEmail('invalid.email');
      expect(result, isNotNull);
    });

    test('valid phone passes phone validation', () {
      final result = ProfileValidator.validatePhone('+1 (555) 123-4567');
      expect(result, null);
    });

    test('invalid phone fails phone validation', () {
      final result = ProfileValidator.validatePhone('123');
      expect(result, isNotNull);
    });
  });

  group('UserProfile Data Model Tests', () {
    test('UserProfile constructor initializes all fields', () {
      final profile = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      expect(profile.fullName, 'John Smith');
      expect(profile.email, 'john.smith@example.com');
      expect(profile.phone, '+1 (555) 123-4567');
      expect(profile.role, 'Primary Caregiver');
      expect(profile.careNotes, 'Requires large text');
    });

    test('copyWith creates new profile with updated fields', () {
      final profile = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final updated = profile.copyWith(fullName: 'Jane Smith');

      expect(updated.fullName, 'Jane Smith');
      expect(updated.email, 'john.smith@example.com');
      expect(updated.phone, '+1 (555) 123-4567');
    });

    test('copyWith preserves original profile', () {
      final profile = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final updated = profile.copyWith(fullName: 'Jane Smith');

      expect(profile.fullName, 'John Smith');
      expect(updated.fullName, 'Jane Smith');
    });

    test('isEqual returns true for identical profiles', () {
      final profile1 = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final profile2 = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      expect(profile1.isEqual(profile2), true);
    });

    test('isEqual returns false for different profiles', () {
      final profile1 = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final profile2 = UserProfile(
        fullName: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+1 (555) 987-6543',
        role: 'Secondary Caregiver',
        careNotes: 'Requires high contrast',
      );

      expect(profile1.isEqual(profile2), false);
    });

    test('isEqual returns false if only one field differs', () {
      final profile1 = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final profile2 = profile1.copyWith(email: 'different@example.com');

      expect(profile1.isEqual(profile2), false);
    });
  });

  group('Profile Change Detection Tests', () {
    test('initial profile and unchanged profile are equal', () {
      final initial = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Patient requires high contrast mode and large text for visual impairment.',
      );

      final current = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Patient requires high contrast mode and large text for visual impairment.',
      );

      expect(initial.isEqual(current), true);
    });

    test('changing name marks profile as changed', () {
      final initial = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final modified = initial.copyWith(fullName: 'Jane Smith');

      expect(initial.isEqual(modified), false);
    });

    test('all fields can be updated and detected', () {
      final initial = UserProfile(
        fullName: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        role: 'Primary Caregiver',
        careNotes: 'Requires large text',
      );

      final modified = initial.copyWith(
        fullName: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+1 (555) 987-6543',
        role: 'Secondary Caregiver',
        careNotes: 'Requires high contrast',
      );

      expect(initial.isEqual(modified), false);
    });
  });
}
