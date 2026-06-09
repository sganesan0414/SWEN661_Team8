import 'package:flutter_test/flutter_test.dart';

// Data model for account creation
class AccountData {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final bool agreeToTerms;
  final int currentStep;

  const AccountData({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.agreeToTerms = false,
    this.currentStep = 0,
  });

  AccountData copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? agreeToTerms,
    int? currentStep,
  }) {
    return AccountData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  bool isEqual(AccountData other) {
    return name == other.name &&
        email == other.email &&
        phone == other.phone &&
        password == other.password &&
        confirmPassword == other.confirmPassword &&
        agreeToTerms == other.agreeToTerms &&
        currentStep == other.currentStep;
  }

  bool isEmpty() {
    return name.isEmpty &&
        email.isEmpty &&
        phone.isEmpty &&
        password.isEmpty &&
        confirmPassword.isEmpty;
  }
}

// Utility class for account creation validation
class AccountValidator {
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;

  static bool isValidName(String name) {
    return name.isNotEmpty && name.trim().length >= 2;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?1?\s?(\(?\d{3}\)?[\s.-]?)?\d{3}[\s.-]?\d{4}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isPasswordLongEnough(String password) {
    return password.length >= minPasswordLength;
  }

  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static bool agreeToTerms(bool agreed) {
    return agreed;
  }

  static String? validateAccountData(AccountData data) {
    if (!isValidName(data.name)) {
      return 'Please enter a valid name (at least 2 characters)';
    }
    if (!isValidEmail(data.email)) {
      return 'Please enter a valid email address';
    }
    if (!isValidPhone(data.phone)) {
      return 'Please enter a valid phone number';
    }
    if (!isPasswordLongEnough(data.password)) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (!doPasswordsMatch(data.password, data.confirmPassword)) {
      return 'Passwords do not match';
    }
    if (!agreeToTerms(data.agreeToTerms)) {
      return 'Please agree to Terms of Service and Privacy Policy';
    }
    return null;
  }

  static String? validateNameStep(String name) {
    if (!isValidName(name)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  static String? validateEmailStep(String email) {
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhoneStep(String phone) {
    if (!isValidPhone(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validatePasswordStep(String password, String confirmPassword) {
    if (!isPasswordLongEnough(password)) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (!doPasswordsMatch(password, confirmPassword)) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateTermsStep(bool agreeToTerms) {
    if (!agreeToTerms) {
      return 'Please agree to Terms of Service and Privacy Policy';
    }
    return null;
  }
}

// Utility class for form state management
class FormStateManager {
  static bool canProceedToNextStep(AccountData data, int currentStep) {
    switch (currentStep) {
      case 0:
        return AccountValidator.isValidName(data.name) &&
            AccountValidator.isValidEmail(data.email) &&
            AccountValidator.isValidPhone(data.phone);
      case 1:
        return AccountValidator.isPasswordLongEnough(data.password) &&
            AccountValidator.doPasswordsMatch(data.password, data.confirmPassword);
      case 2:
        return AccountValidator.agreeToTerms(data.agreeToTerms);
      default:
        return false;
    }
  }

  static int getNextStep(int currentStep, int totalSteps) {
    if (currentStep < totalSteps - 1) {
      return currentStep + 1;
    }
    return currentStep;
  }

  static int getPreviousStep(int currentStep) {
    if (currentStep > 0) {
      return currentStep - 1;
    }
    return currentStep;
  }

  static bool isFirstStep(int currentStep) {
    return currentStep == 0;
  }

  static bool isLastStep(int currentStep, int totalSteps) {
    return currentStep == totalSteps - 1;
  }

  static double getProgressPercentage(int currentStep, int totalSteps) {
    return (currentStep + 1) / totalSteps;
  }
}

// Utility class for password visibility management
class PasswordVisibilityManager {
  static bool togglePasswordVisibility(bool currentVisibility) {
    return !currentVisibility;
  }

  static String getVisibilityToggleLabel(bool isVisible) {
    return isVisible ? 'Hide password' : 'Show password';
  }
}

void main() {
  group('AccountValidator Tests', () {
    test('valid name passes validation', () {
      expect(AccountValidator.isValidName('John Doe'), true);
    });

    test('empty name fails validation', () {
      expect(AccountValidator.isValidName(''), false);
    });

    test('single character name fails validation', () {
      expect(AccountValidator.isValidName('J'), false);
    });

    test('whitespace only name fails validation', () {
      expect(AccountValidator.isValidName('   '), false);
    });

    test('valid email passes validation', () {
      expect(AccountValidator.isValidEmail('john.doe@example.com'), true);
    });

    test('email without @ fails validation', () {
      expect(AccountValidator.isValidEmail('johndoeexample.com'), false);
    });

    test('email without domain fails validation', () {
      expect(AccountValidator.isValidEmail('john@'), false);
    });

    test('email without extension fails validation', () {
      expect(AccountValidator.isValidEmail('john@example'), false);
    });

    test('valid phone passes validation', () {
      expect(AccountValidator.isValidPhone('+1 (555) 123-4567'), true);
    });

    test('phone with different format passes validation', () {
      expect(AccountValidator.isValidPhone('555-123-4567'), true);
    });

    test('invalid phone fails validation', () {
      expect(AccountValidator.isValidPhone('123'), false);
    });

    test('password with 8 characters is valid', () {
      expect(AccountValidator.isPasswordLongEnough('12345678'), true);
    });

    test('password with more than 8 characters is valid', () {
      expect(AccountValidator.isPasswordLongEnough('password123'), true);
    });

    test('password with less than 8 characters fails validation', () {
      expect(AccountValidator.isPasswordLongEnough('pass123'), false);
    });

    test('matching passwords return true', () {
      expect(
        AccountValidator.doPasswordsMatch('password123', 'password123'),
        true,
      );
    });

    test('non-matching passwords return false', () {
      expect(
        AccountValidator.doPasswordsMatch('password123', 'password456'),
        false,
      );
    });

    test('agreed to terms returns true', () {
      expect(AccountValidator.agreeToTerms(true), true);
    });

    test('not agreed to terms returns false', () {
      expect(AccountValidator.agreeToTerms(false), false);
    });

    test('validateAccountData returns null for valid data', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
      );

      expect(AccountValidator.validateAccountData(data), null);
    });

    test('validateAccountData returns error for invalid name', () {
      final data = AccountData(
        name: 'J',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
      );

      expect(AccountValidator.validateAccountData(data), isNotNull);
    });

    test('validateAccountData returns error for invalid email', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'invalid.email',
        phone: '+1 (555) 123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
      );

      expect(AccountValidator.validateAccountData(data), isNotNull);
    });

    test('validateAccountData returns error for mismatched passwords', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        password: 'password123',
        confirmPassword: 'password456',
        agreeToTerms: true,
      );

      expect(AccountValidator.validateAccountData(data), isNotNull);
    });

    test('validateAccountData returns error for not agreed to terms', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: false,
      );

      expect(AccountValidator.validateAccountData(data), isNotNull);
      expect(AccountValidator.validateAccountData(data), contains('agree'));
    });

    test('validateNameStep validates name only', () {
      expect(AccountValidator.validateNameStep('John Doe'), null);
      expect(AccountValidator.validateNameStep('J'), isNotNull);
    });

    test('validateEmailStep validates email only', () {
      expect(
        AccountValidator.validateEmailStep('john.doe@example.com'),
        null,
      );
      expect(AccountValidator.validateEmailStep('invalid'), isNotNull);
    });

    test('validatePhoneStep validates phone only', () {
      expect(
        AccountValidator.validatePhoneStep('+1 (555) 123-4567'),
        null,
      );
      expect(AccountValidator.validatePhoneStep('123'), isNotNull);
    });

    test('validatePasswordStep validates both passwords', () {
      expect(
        AccountValidator.validatePasswordStep('password123', 'password123'),
        null,
      );
      expect(
        AccountValidator.validatePasswordStep('pass123', 'pass123'),
        isNotNull,
      );
    });

    test('validateTermsStep validates terms agreement', () {
      expect(AccountValidator.validateTermsStep(true), null);
      expect(AccountValidator.validateTermsStep(false), isNotNull);
    });
  });

  group('AccountData Model Tests', () {
    test('default constructor initializes empty fields', () {
      final data = const AccountData();

      expect(data.name, '');
      expect(data.email, '');
      expect(data.phone, '');
      expect(data.password, '');
      expect(data.confirmPassword, '');
      expect(data.agreeToTerms, false);
      expect(data.currentStep, 0);
    });

    test('custom constructor initializes with values', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
        currentStep: 2,
      );

      expect(data.name, 'John Doe');
      expect(data.email, 'john@example.com');
      expect(data.phone, '555-123-4567');
      expect(data.password, 'password123');
      expect(data.confirmPassword, 'password123');
      expect(data.agreeToTerms, true);
      expect(data.currentStep, 2);
    });

    test('copyWith updates single field', () {
      final data = const AccountData();
      final updated = data.copyWith(name: 'John Doe');

      expect(updated.name, 'John Doe');
      expect(updated.email, '');
      expect(updated.agreeToTerms, false);
    });

    test('copyWith preserves original data', () {
      final data = const AccountData(name: 'John Doe');
      final updated = data.copyWith(name: 'Jane Doe');

      expect(data.name, 'John Doe');
      expect(updated.name, 'Jane Doe');
    });

    test('isEqual returns true for identical data', () {
      final data1 = AccountData(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
        currentStep: 1,
      );

      final data2 = AccountData(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-123-4567',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTerms: true,
        currentStep: 1,
      );

      expect(data1.isEqual(data2), true);
    });

    test('isEqual returns false for different data', () {
      final data1 = const AccountData(name: 'John Doe');
      final data2 = const AccountData(name: 'Jane Doe');

      expect(data1.isEqual(data2), false);
    });

    test('isEmpty returns true for empty data', () {
      final data = const AccountData();
      expect(data.isEmpty(), true);
    });

    test('isEmpty returns false when any field is populated', () {
      final data = const AccountData(name: 'John Doe');
      expect(data.isEmpty(), false);
    });
  });

  group('FormStateManager Tests', () {
    test('canProceedToNextStep returns true when step 0 is valid', () {
      final data = AccountData(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-123-4567',
      );

      expect(FormStateManager.canProceedToNextStep(data, 0), true);
    });

    test('canProceedToNextStep returns false when step 0 is invalid', () {
      final data = const AccountData(name: 'J');

      expect(FormStateManager.canProceedToNextStep(data, 0), false);
    });

    test('canProceedToNextStep returns true when step 1 is valid', () {
      final data = AccountData(
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(FormStateManager.canProceedToNextStep(data, 1), true);
    });

    test('canProceedToNextStep returns false when step 1 is invalid', () {
      final data = const AccountData(password: 'pass123');

      expect(FormStateManager.canProceedToNextStep(data, 1), false);
    });

    test('canProceedToNextStep returns true when step 2 is valid', () {
      final data = const AccountData(agreeToTerms: true);

      expect(FormStateManager.canProceedToNextStep(data, 2), true);
    });

    test('canProceedToNextStep returns false when step 2 is invalid', () {
      final data = const AccountData(agreeToTerms: false);

      expect(FormStateManager.canProceedToNextStep(data, 2), false);
    });

    test('getNextStep increments current step', () {
      expect(FormStateManager.getNextStep(0, 3), 1);
      expect(FormStateManager.getNextStep(1, 3), 2);
    });

    test('getNextStep does not exceed total steps', () {
      expect(FormStateManager.getNextStep(2, 3), 2);
    });

    test('getPreviousStep decrements current step', () {
      expect(FormStateManager.getPreviousStep(2), 1);
      expect(FormStateManager.getPreviousStep(1), 0);
    });

    test('getPreviousStep does not go below 0', () {
      expect(FormStateManager.getPreviousStep(0), 0);
    });

    test('isFirstStep returns true for step 0', () {
      expect(FormStateManager.isFirstStep(0), true);
    });

    test('isFirstStep returns false for other steps', () {
      expect(FormStateManager.isFirstStep(1), false);
      expect(FormStateManager.isFirstStep(2), false);
    });

    test('isLastStep returns true for last step', () {
      expect(FormStateManager.isLastStep(2, 3), true);
    });

    test('isLastStep returns false for non-last steps', () {
      expect(FormStateManager.isLastStep(0, 3), false);
      expect(FormStateManager.isLastStep(1, 3), false);
    });

    test('getProgressPercentage calculates correctly', () {
      expect(
        FormStateManager.getProgressPercentage(0, 3),
        closeTo(0.333, 0.01),
      );
      expect(FormStateManager.getProgressPercentage(1, 3), closeTo(0.667, 0.01));
      expect(FormStateManager.getProgressPercentage(2, 3), closeTo(1.0, 0.01));
    });
  });

  group('PasswordVisibilityManager Tests', () {
    test('togglePasswordVisibility changes visibility state', () {
      expect(PasswordVisibilityManager.togglePasswordVisibility(true), false);
      expect(PasswordVisibilityManager.togglePasswordVisibility(false), true);
    });

    test('getVisibilityToggleLabel returns correct text', () {
      expect(
        PasswordVisibilityManager.getVisibilityToggleLabel(true),
        'Hide password',
      );
      expect(
        PasswordVisibilityManager.getVisibilityToggleLabel(false),
        'Show password',
      );
    });
  });

  group('Account Creation Flow Tests', () {
    test('complete flow validates all steps', () {
      var data = const AccountData();

      data = data.copyWith(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-123-4567',
      );
      expect(FormStateManager.canProceedToNextStep(data, 0), true);

      data = data.copyWith(
        password: 'password123',
        confirmPassword: 'password123',
      );
      expect(FormStateManager.canProceedToNextStep(data, 1), true);

      data = data.copyWith(agreeToTerms: true);
      expect(FormStateManager.canProceedToNextStep(data, 2), true);

      expect(AccountValidator.validateAccountData(data), null);
    });

    test('incomplete flow validation fails appropriately', () {
      var data = const AccountData();

      data = data.copyWith(name: 'John Doe');
      expect(FormStateManager.canProceedToNextStep(data, 0), false);

      data = data.copyWith(email: 'john@example.com');
      expect(FormStateManager.canProceedToNextStep(data, 0), false);

      data = data.copyWith(phone: '555-123-4567');
      expect(FormStateManager.canProceedToNextStep(data, 0), true);
    });

    test('step progression tracks correctly', () {
      var step = 0;
      const totalSteps = 3;

      expect(FormStateManager.isFirstStep(step), true);
      expect(FormStateManager.isLastStep(step, totalSteps), false);

      step = FormStateManager.getNextStep(step, totalSteps);
      expect(step, 1);

      step = FormStateManager.getNextStep(step, totalSteps);
      expect(step, 2);

      expect(FormStateManager.isLastStep(step, totalSteps), true);

      step = FormStateManager.getPreviousStep(step);
      expect(step, 1);
    });
  });
}
