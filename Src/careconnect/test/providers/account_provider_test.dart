import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/providers/account_provider.dart';

void main() {
  group('AccountNotifier', () {
    test('initial state is not logged in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(accountProvider).isLoggedIn, isFalse);
    });

    test('signIn sets isLoggedIn to true', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(accountProvider.notifier).signIn('test@example.com', 'password');
      expect(container.read(accountProvider).isLoggedIn, isTrue);
      expect(container.read(accountProvider).email, 'test@example.com');
    });

    test('signOut clears state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(accountProvider.notifier).signIn('test@example.com', 'password');
      container.read(accountProvider.notifier).signOut();
      final state = container.read(accountProvider);
      expect(state.isLoggedIn, isFalse);
      expect(state.email, isEmpty);
    });
  });
}
