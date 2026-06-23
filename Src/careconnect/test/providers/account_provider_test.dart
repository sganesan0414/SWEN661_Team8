import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careconnect/providers/account_provider.dart';

void main() {
  setUp(() {
    // Start each test with empty persisted storage.
    SharedPreferences.setMockInitialValues({});
  });

  group('AccountNotifier', () {
    test('initial state is not logged in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(accountProvider).isLoggedIn, isFalse);
    });

    test('register saves an account and returns no error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final error = await container.read(accountProvider.notifier).register(
            name: 'Test User',
            email: 'test@example.com',
            phone: '555-1234',
            password: 'password123',
          );
      expect(error, isNull);
    });

    test('register rejects a duplicate email', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Test User',
        email: 'dupe@example.com',
        phone: '555',
        password: 'password123',
      );
      final error = await notifier.register(
        name: 'Other User',
        email: 'dupe@example.com',
        phone: '555',
        password: 'different',
      );
      expect(error, contains('already exists'));
    });

    test('signIn succeeds with correct credentials after registering',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555',
        password: 'secret123',
      );

      final error = await notifier.signIn('jane@example.com', 'secret123');
      expect(error, isNull);

      final state = container.read(accountProvider);
      expect(state.isLoggedIn, isTrue);
      expect(state.email, 'jane@example.com');
      expect(state.displayName, 'Jane Doe');
    });

    test('signIn is case-insensitive for the email', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Jane Doe',
        email: 'Jane@Example.com',
        phone: '555',
        password: 'secret123',
      );
      final error = await notifier.signIn('jane@example.com', 'secret123');
      expect(error, isNull);
      expect(container.read(accountProvider).isLoggedIn, isTrue);
    });

    test('signIn fails with a wrong password', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555',
        password: 'secret123',
      );
      final error = await notifier.signIn('jane@example.com', 'wrongpass');
      expect(error, isNotNull);
      expect(container.read(accountProvider).isLoggedIn, isFalse);
    });

    test('signIn fails for an unknown email', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final error = await container
          .read(accountProvider.notifier)
          .signIn('nobody@example.com', 'whatever');
      expect(error, isNotNull);
      expect(container.read(accountProvider).isLoggedIn, isFalse);
    });

    test('signInTrusted logs in as the most recent account', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Pin User',
        email: 'pin@example.com',
        phone: '555',
        password: 'pinpass12',
      );
      await notifier.signInTrusted();
      final state = container.read(accountProvider);
      expect(state.isLoggedIn, isTrue);
      expect(state.displayName, 'Pin User');
    });

    test('resetPassword updates the password for an existing account', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Reset User',
        email: 'reset@example.com',
        phone: '555',
        password: 'oldpass12',
      );

      final resetError =
          await notifier.resetPassword('reset@example.com', 'newpass123');
      expect(resetError, isNull);

      // Old password no longer works; new password does.
      expect(await notifier.signIn('reset@example.com', 'oldpass12'), isNotNull);
      expect(await notifier.signIn('reset@example.com', 'newpass123'), isNull);
      expect(container.read(accountProvider).isLoggedIn, isTrue);
    });

    test('resetPassword fails for an unknown email', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final error = await container
          .read(accountProvider.notifier)
          .resetPassword('nobody@example.com', 'newpass123');
      expect(error, contains('No account found'));
    });

    test('resetPassword rejects a too-short password', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Short Pw',
        email: 'short@example.com',
        phone: '555',
        password: 'oldpass12',
      );
      final error = await notifier.resetPassword('short@example.com', 'abc');
      expect(error, contains('at least 8'));
    });

    test('signOut clears state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(accountProvider.notifier);
      await notifier.register(
        name: 'Test',
        email: 'test@example.com',
        phone: '555',
        password: 'password123',
      );
      await notifier.signIn('test@example.com', 'password123');
      notifier.signOut();
      final state = container.read(accountProvider);
      expect(state.isLoggedIn, isFalse);
      expect(state.email, isEmpty);
    });
  });
}
