import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _accountsKey = 'careconnect_accounts';

  // In-memory mirror of the stored accounts (email -> {name, phone, password}).
  // SharedPreferences is the source of truth across app restarts; this cache
  // keeps things working in environments where the plugin is unavailable
  // (e.g. unit tests), so registration/sign-in never hard-fail.
  final Map<String, Map<String, String>> _cache = {};

  @override
  AccountState build() => const AccountState();

  /// Loads accounts, merging any persisted records into the in-memory cache.
  Future<Map<String, Map<String, String>>> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_accountsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _cache[entry.key] =
              Map<String, String>.from(entry.value as Map);
        }
      }
    } catch (_) {
      // Plugin unavailable (tests / first run) — fall back to the cache.
    }
    return _cache;
  }

  /// Best-effort persist of the in-memory cache to disk.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountsKey, jsonEncode(_cache));
    } catch (_) {
      // Persistence unavailable — cache still serves the current session.
    }
  }

  /// Creates and saves a new account.
  /// Returns `null` on success, or a human-readable error message on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 800));

    final key = email.trim().toLowerCase();
    if (key.isEmpty || !key.contains('@')) {
      state = state.copyWith(isLoading: false);
      return 'Please enter a valid email address';
    }
    if (name.trim().isEmpty) {
      state = state.copyWith(isLoading: false);
      return 'Please enter your name';
    }

    final accounts = await _loadAccounts();
    if (accounts.containsKey(key)) {
      state = state.copyWith(isLoading: false);
      return 'An account with this email already exists';
    }

    _cache[key] = {
      'name': name.trim(),
      'phone': phone.trim(),
      'password': password,
    };
    await _persist();

    state = state.copyWith(isLoading: false);
    return null;
  }

  /// Validates credentials against saved accounts and signs in on success.
  /// Returns `null` on success, or an error message on failure.
  Future<String?> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1000));

    final key = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final account = accounts[key];

    if (account == null || account['password'] != password) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email or password',
      );
      return 'Invalid email or password';
    }

    final name = account['name'] ?? '';
    state = state.copyWith(
      isLoggedIn: true,
      email: key,
      displayName: name.isNotEmpty ? name : 'there',
      isLoading: false,
      errorMessage: null,
    );
    return null;
  }

  /// Passwordless sign-in for biometric / PIN unlock. Signs in as the most
  /// recently registered account, or a guest session if none exist yet.
  Future<void> signInTrusted() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500));

    final accounts = await _loadAccounts();
    if (accounts.isEmpty) {
      state = state.copyWith(
        isLoggedIn: true,
        email: '',
        displayName: 'there',
        isLoading: false,
      );
      return;
    }

    final email = accounts.keys.last;
    final account = accounts[email]!;
    final name = account['name'] ?? '';
    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      displayName: name.isNotEmpty ? name : 'there',
      isLoading: false,
    );
  }

  /// Resets the password for an existing account (offline "forgot password").
  /// Returns `null` on success, or a human-readable error message on failure.
  Future<String?> resetPassword(String email, String newPassword) async {
    final key = email.trim().toLowerCase();
    if (key.isEmpty || !key.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (newPassword.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final accounts = await _loadAccounts();
    if (!accounts.containsKey(key)) {
      return 'No account found with this email';
    }

    _cache[key]!['password'] = newPassword;
    await _persist();
    return null;
  }

  void signOut() {
    state = const AccountState();
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
    final key = state.email;
    if (key.isNotEmpty && _cache.containsKey(key)) {
      _cache[key]!['name'] = name;
      _persist();
    }
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String newPassword) {
    final key = state.email;
    if (key.isNotEmpty && _cache.containsKey(key)) {
      _cache[key]!['password'] = newPassword;
      _persist();
    }
  }
}

final accountProvider =
    NotifierProvider<AccountNotifier, AccountState>(AccountNotifier.new);
