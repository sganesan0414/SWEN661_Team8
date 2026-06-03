import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _buttonCooling = false;

  void _goToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _handleBiometric(String method) async {
    HapticFeedback.mediumImpact();
    // TODO: Authentiation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$method authentication requested'),
        duration: const Duration(seconds: 2),
      ),
    );
    _goToDashboard();
  }

  Future<void> _handleSignIn() async {
    if (_buttonCooling) return;            
    setState(() { _buttonCooling = true; _isLoading = true; });
    HapticFeedback.lightImpact();          

    // TODO: Real auth delay. We can remove this
    await Future.delayed(const Duration(milliseconds: 1500)); 

    if (mounted) setState(() { _isLoading = false; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _buttonCooling = false; });
    _goToDashboard();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

              Semantics(
                label: 'Email address input',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Semantics(
                label: 'Password input',
                child: TextFormField(
                  controller: _passwordController,
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
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text('Forgot Password?', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 24),

              Semantics(
                button: true,
                label: 'Sign in to your account',
                child: ElevatedButton.icon(
                  onPressed: _buttonCooling ? null : _handleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.login_outlined),
                  label: Text(_isLoading ? 'Signing in…' : 'Sign In'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 58),
                    textStyle: AppTextStyles.titleLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pin_outlined, size: 20),
                label: const Text('Use PIN instead'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: AppTextStyles.bodyMedium,
                ),
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
    return Semantics(
      button: true,
      label: 'Sign in with $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
              Icon(icon, size: 36, color: AppColors.textPrimary),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}