import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/account_provider.dart';
import 'dashboard_screen.dart';

const _correctPin = '1234';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  bool _hasError = false;
  /// Incremented on each failed attempt so the shake replays even when two
  /// wrong PINs in a row leave `_hasError` unchanged.
  int _errorCount = 0;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _hasError = false;
    });
    if (_pin.length == 4) _submit();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_pin == _correctPin) {
      await ref.read(accountProvider.notifier).signInTrusted();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorCount++;
        _pin = '';
      });
      showAppSnackBar(
        context,
        'Incorrect PIN. Please try again.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: LabeledBackButton(label: 'Login'),
        leadingWidth: AppSizing.backButtonWidth,
        title: const Text('Enter PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pin_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Enter your 4-digit PIN', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 24,
                child: Semantics(
                  liveRegion: true,
                  child: AnimatedOpacity(
                    opacity: _hasError ? 1 : 0,
                    duration: context.motion(AppDurations.fast),
                    child: Text(
                      'Incorrect PIN',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // The shake is a redundant cue: the colour change and the
              // "Incorrect PIN" text carry the same meaning for anyone with
              // reduced motion enabled.
              ShakeOnChange(
                trigger: _errorCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: context.motion(AppDurations.fast),
                      curve: AppCurves.standard,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? (_hasError ? AppColors.danger : AppColors.primary)
                            : Colors.transparent,
                        border: Border.all(
                          color: _hasError ? AppColors.danger : AppColors.primary,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 48),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final d in ['1','2','3','4','5','6','7','8','9'])
                    _PinKey(label: d, onTap: () => _onDigit(d)),
                  const SizedBox.shrink(),
                  _PinKey(label: '0', onTap: () => _onDigit('0')),
                  _PinKey(
                    icon: Icons.backspace_outlined,
                    onTap: _onDelete,
                    semanticsLabel: 'Delete last digit',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final String? semanticsLabel;

  const _PinKey({this.label, this.icon, required this.onTap, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: label != null
                ? Text(label!, style: AppTextStyles.headlineMedium)
                : Icon(icon, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
