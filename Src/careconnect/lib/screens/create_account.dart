import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/widgets.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../providers/account_provider.dart';
import 'login_screen.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  // Account creation is a single screen today; the indicator shows where that
  // sits in the wider flow rather than tracking sub-steps within this screen.
  static const int _totalSteps = 3;
  final int _currentStep = 0;

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleContinue() async {
    if (!_agreeToTerms) {
      showAppSnackBar(context, 'Please agree to Terms of Service and Privacy Policy', duration: const Duration(seconds: 2));
      return;
    }

    if (_passwordController.text.length < 8) {
      showAppSnackBar(context, 'Password must be at least 8 characters', duration: const Duration(seconds: 2));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showAppSnackBar(context, 'Passwords do not match', duration: const Duration(seconds: 2));
      return;
    }

    setState(() { _isLoading = true; });
    HapticFeedback.lightImpact();

    // Persist the new account so the user can sign in with these credentials.
    final error = await ref.read(accountProvider.notifier).register(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (error != null) {
      showAppSnackBar(context, error, duration: const Duration(seconds: 2));
      return;
    }

    showAppSnackBar(context, 'Account created! Please sign in.', duration: const Duration(seconds: 2));
    _goToLogin();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lock Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_outlined, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 28),

              // Title
              Text('Create Your Account', style: AppTextStyles.displayLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Join CareConnect to manage your health journey',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Progress Indicator (3 steps)
              Semantics(
                label: 'Step ${_currentStep + 1} of $_totalSteps',
                child: Row(
                  children: [
                    for (var i = 0; i < _totalSteps; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      _ProgressStep(isActive: _currentStep >= i),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),

              // Full Name
              Semantics(
                label: 'Full name input',
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email Address
              Semantics(
                label: 'Email address input',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'john.doe@example.com',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              Semantics(
                label: 'Phone number input',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '(555) 123-4567',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              Semantics(
                label: 'Password input',
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
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
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Must be at least 8 characters', style: AppTextStyles.caption),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              Semantics(
                label: 'Confirm password input',
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    suffixIcon: Semantics(
                      label: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                      button: true,
                      child: IconButton(
                        tooltip: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Privacy Agreement.
              // No outer Semantics wrapper here: it would merge with and mask the
              // checkbox's own 'Agreement checkbox' label. The RichText below already
              // announces the full "I agree to the Terms of Service…" text.
              Row(
                  children: [
                    Semantics(
                      label: 'Agreement checkbox',
                      button: true,
                      enabled: true,
                      checked: _agreeToTerms,
                      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Continue Button
              Semantics(
                button: true,
                label: 'Continue to next step',
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleContinue,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_outlined),
                  label: Text(_isLoading ? 'Creating Account…' : 'Continue'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 58),
                    textStyle: AppTextStyles.titleLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sign In Link — Wrap (not Row) so it reflows instead of
              // overflowing horizontally at large text scales (WCAG 1.4.10 Reflow).
              Semantics(
                label: 'Go back to sign in',
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Sign In', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final bool isActive;

  const _ProgressStep({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: context.motion(AppDurations.normal),
        curve: AppCurves.standard,
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}