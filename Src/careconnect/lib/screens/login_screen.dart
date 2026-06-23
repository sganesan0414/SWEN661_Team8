import 'package:careconnect/screens/create_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';
import '../providers/account_provider.dart';
import 'dashboard_screen.dart';
import 'pin_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _buttonCooling = false;

  void _goToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _goToCreateAccount() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
    );
  }


  Future<void> _handleBiometric(String method) async {
    HapticFeedback.mediumImpact();
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$method not available on this device')),
      );
      return;
    }
    final didAuth = await auth.authenticate(
      localizedReason: 'Sign in to CareConnect with $method',
      biometricOnly: true,
    );
    if (!mounted) return;
    if (didAuth) {
      await ref.read(accountProvider.notifier).signInTrusted();
      if (mounted) _goToDashboard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$method authentication failed')),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final resetEmail = await showDialog<String>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(initialEmail: _emailController.text),
    );
    if (!mounted || resetEmail == null) return;
    // Pre-fill the email so the user can sign in immediately with the new password.
    _emailController.text = resetEmail;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset. Please sign in with your new password.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_buttonCooling) return;
    setState(() => _buttonCooling = true);
    HapticFeedback.lightImpact();

    final error = await ref
        .read(accountProvider.notifier)
        .signIn(_emailController.text, _passwordController.text);

    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), duration: const Duration(seconds: 2)),
      );
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _buttonCooling = false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountState>(accountProvider, (previous, next) {
      if (!previous!.isLoggedIn && next.isLoggedIn) {
        _goToDashboard();
      }
    });

    final account = ref.watch(accountProvider);
    final isLoading = account.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 28),

              Text('Welcome Back', style: AppTextStyles.displayLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to CareConnect',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Quick Sign In', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BiometricButton(
                      icon: Icons.fingerprint,
                      label: 'Fingerprint',
                      onTap: () => _handleBiometric('Fingerprint'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _BiometricButton(
                      icon: Icons.face_outlined,
                      label: 'Face ID',
                      onTap: () => _handleBiometric('Face ID'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or sign in with email', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 24),

              // WCAG 2.1 SC 2.1.1: Full keyboard navigation via FocusTraversalGroup
              FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: 'Email address input',
                      child: TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'user@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignIn(),
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: Semantics(
                          label: _obscurePassword ? 'Show password' : 'Hide password',
                          button: true,
                          child: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  label: 'Reset your password',
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text('Forgot Password?', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Semantics(
                button: true,
                label: 'Sign in to your account',
                child: ElevatedButton.icon(
                  onPressed: _buttonCooling ? null : _handleSignIn,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.login_outlined),
                  label: Text((_buttonCooling || isLoading) ? 'Signing in…' : 'Sign In'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 58),
                    textStyle: AppTextStyles.titleLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PinEntryScreen()),
                ),
                icon: const Icon(Icons.pin_outlined, size: 20),
                label: const Text('Use PIN instead'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: AppTextStyles.bodyMedium,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Dont have an account? ', style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => _goToCreateAccount(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text('Create Account', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people_outline, size: 20),
                label: const Text('Need help? Contact my Caregiver'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Offline "Forgot Password" dialog: verifies the email belongs to a saved
/// account and sets a new password. Pops with the email string on success,
/// or null if cancelled.
class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_newPasswordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    final error = await ref.read(accountProvider.notifier).resetPassword(
          _emailController.text,
          _newPasswordController.text,
        );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your account email and a new password.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Account email input',
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'New password input',
              child: TextField(
                controller: _newPasswordController,
                obscureText: _obscure,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: Semantics(
                    label: _obscure ? 'Show password' : 'Hide password',
                    button: true,
                    child: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Confirm new password input',
              child: TextField(
                controller: _confirmController,
                obscureText: _obscure,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
          child: Text(_submitting ? 'Resetting…' : 'Reset Password'),
        ),
      ],
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BiometricButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: 'Sign in with $label',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          // WCAG 2.1 SC 2.4.7: visible focus indicator for keyboard users
          focusColor: AppColors.primaryLight,
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(child: Icon(icon, size: 36, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ExcludeSemantics(child: Text(label, style: AppTextStyles.labelLarge)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
