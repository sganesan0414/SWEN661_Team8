import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/account_provider.dart';
import 'user_profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _highContrastMode = false;
  double _textSize = 16;
  double _contrastLevel = 100;
  bool _screenMagnification = false;
  bool _screenReader = true;
  bool _soundAlerts = false;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: LabeledBackButton(
          label: 'Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 160,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Manage your accessibility preferences',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Account', style: AppTextStyles.titleLarge),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                          ),
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _InfoRow(label: 'Name', value: account.displayName.isNotEmpty ? account.displayName : '—'),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Email', value: account.email.isNotEmpty ? account.email : '—'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _SettingsCard(
                icon: Icons.visibility_outlined,
                title: 'Visual Settings',
                subtitle: 'Adjust display options for better visibility',
                children: [
                  _ToggleRow(
                    label: 'High Contrast Mode',
                    description: 'Enhance color contrast for improved readability',
                    semanticsLabel: 'High contrast mode toggle',
                    value: _highContrastMode,
                    onChanged: (v) => setState(() => _highContrastMode = v),
                  ),
                  const SizedBox(height: 20),
                  Text('Text Size', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          slider: true,
                          label: 'Text size slider',
                          onIncrease: () { if (_textSize < 24) setState(() => _textSize += 1); },
                          onDecrease: () { if (_textSize > 12) setState(() => _textSize -= 1); },
                          child: Slider(
                            value: _textSize,
                            min: 12,
                            max: 24,
                            divisions: 12,
                            onChanged: (v) => setState(() => _textSize = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 44,
                        child: Text('${_textSize.toInt()}px', style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Contrast Level', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          slider: true,
                          label: 'Contrast level slider',
                          onIncrease: () { if (_contrastLevel < 100) setState(() => _contrastLevel += 5); },
                          onDecrease: () { if (_contrastLevel > 50) setState(() => _contrastLevel -= 5); },
                          child: Slider(
                            value: _contrastLevel,
                            min: 50,
                            max: 100,
                            divisions: 10,
                            onChanged: (v) => setState(() => _contrastLevel = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 44,
                        child: Text('${_contrastLevel.toInt()}%', style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ToggleRow(
                    label: 'Screen Magnification',
                    description: 'Enable zoom features for easier viewing',
                    semanticsLabel: 'Screen magnification toggle',
                    value: _screenMagnification,
                    onChanged: (v) => setState(() => _screenMagnification = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SettingsCard(
                icon: Icons.volume_up_outlined,
                title: 'Audio & Alerts',
                subtitle: 'Configure sound and screen reader options',
                children: [
                  _ToggleRow(
                    label: 'Screen Reader',
                    description: 'Enable text-to-speech for all content',
                    semanticsLabel: 'Screen reader toggle',
                    value: _screenReader,
                    onChanged: (v) => setState(() => _screenReader = v),
                  ),
                  const SizedBox(height: 20),
                  _ToggleRow(
                    label: 'Sound Alerts',
                    description: 'Play audio notifications for important events',
                    semanticsLabel: 'Sound alerts toggle',
                    value: _soundAlerts,
                    onChanged: (v) => setState(() => _soundAlerts = v),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: AppTextStyles.labelLarge),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final String semanticsLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.semanticsLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelLarge),
              const SizedBox(height: 2),
              Text(description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          label: semanticsLabel,
          button: true,
          enabled: true,
          toggled: value,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
