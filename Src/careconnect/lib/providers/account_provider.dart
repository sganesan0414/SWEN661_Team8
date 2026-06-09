import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  final bool isLoggedIn;
  final String email;
  final String displayName;
  final bool isLoading;
  final String? errorMessage;

  const AccountState({
    this.isLoggedIn = false,
    this.email = '',
    this.displayName = '',
    this.isLoading = false,
    this.errorMessage,
  });

  AccountState copyWith({
    bool? isLoggedIn,
    String? email,
    String? displayName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AccountState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AccountNotifier extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      displayName: 'Siva',
      isLoading: false,
    );
  }

  void signOut() {
    state = const AccountState();
  }
}

final accountProvider =
    NotifierProvider<AccountNotifier, AccountState>(AccountNotifier.new);
