import 'package:careconnect/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Visual Settings
  bool _highContrastMode = false;
  double _textSize = 16;
  double _contrastLevel = 100;
  bool _screenMagnification = false;

  // Audio & Alerts
  bool _screenReader = true;
  bool _soundAlerts = false;

  void _goBack() {
    if (!mounted) return;
    //Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Settings', style: AppTextStyles.displayLarge),              
              const SizedBox(height: 8),
              Text(
                'Manage your account and accessibility preferences',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Account Information Section
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
                        Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Account Information', style: AppTextStyles.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update your personal details and contact information',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const Divider(height: 28),

                    // Full Name and Email Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Full Name', style: AppTextStyles.labelLarge),
                              const SizedBox(height: 6),
                              Text('Sarah Johnson', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email Address', style: AppTextStyles.labelLarge),
                              const SizedBox(height: 6),
                              Text('sarah.johnson@email.com', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Phone and Location Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone Number', style: AppTextStyles.labelLarge),
                              const SizedBox(height: 6),
                              Text('(555) 123-4567', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location', style: AppTextStyles.labelLarge),
                              const SizedBox(height: 6),
                              Text('San Francisco, CA', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Change Password Button
                    Semantics(
                      button: true,
                      label: 'Change password',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Change password feature coming soon')),
                          );
                        },
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Visual Settings and Audio & Alerts (2 columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Settings
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Visual Settings', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Adjust display options for better visibility',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),

                          // High Contrast Mode
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('High Contrast Mode', style: AppTextStyles.labelLarge),
                                  Text(
                                    'Enhance color contrast for improved readability',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Semantics(
                                label: 'High contrast mode toggle',
                                button: true,
                                enabled: true,
                                toggled: _highContrastMode,
                                onTap: () => setState(() => _highContrastMode = !_highContrastMode),
                                child: Switch(
                                  value: _highContrastMode,
                                  onChanged: (value) => setState(() => _highContrastMode = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Text Size Slider
                          Text('Text Size', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Semantics(
                                  slider: true,
                                  label: 'Text size slider',
                                  onIncrease: () {
                                    if (_textSize < 24) {
                                      setState(() => _textSize += 1);
                                    }
                                  },
                                  onDecrease: () {
                                    if (_textSize > 12) {
                                      setState(() => _textSize -= 1);
                                    }
                                  },
                                  child: Slider(
                                    value: _textSize,
                                    min: 12,
                                    max: 24,
                                    divisions: 12,
                                    onChanged: (value) => setState(() => _textSize = value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('${_textSize.toInt()}px', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Contrast Level Slider
                          Text('Contrast Level', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Semantics(
                                  slider: true,
                                  label: 'Contrast level slider',
                                  onIncrease: () {
                                    if (_contrastLevel < 100) {
                                      setState(() => _contrastLevel += 5);
                                    }
                                  },
                                  onDecrease: () {
                                    if (_contrastLevel > 50) {
                                      setState(() => _contrastLevel -= 5);
                                    }
                                  },
                                  child: Slider(
                                    value: _contrastLevel,
                                    min: 50,
                                    max: 100,
                                    divisions: 10,
                                    onChanged: (value) => setState(() => _contrastLevel = value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('${_contrastLevel.toInt()}%', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Screen Magnification
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Screen Magnification', style: AppTextStyles.labelLarge),
                                  Text(
                                    'Enable zoom features for easier viewing',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Semantics(
                                label: 'Screen magnification toggle',
                                button: true,
                                enabled: true,
                                toggled: _screenMagnification,
                                onTap: () => setState(() => _screenMagnification = !_screenMagnification),
                                child: Switch(
                                  value: _screenMagnification,
                                  onChanged: (value) => setState(() => _screenMagnification = value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Audio & Alerts
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Audio & Alerts', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Configure sound and screen reader options',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),

                          // Screen Reader
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Screen Reader', style: AppTextStyles.labelLarge),
                                  Text(
                                    'Enable text-to-speech for all content',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Semantics(
                                label: 'Screen reader toggle',
                                button: true,
                                enabled: true,
                                toggled: _screenReader,
                                onTap: () => setState(() => _screenReader = !_screenReader),
                                child: Switch(
                                  value: _screenReader,
                                  onChanged: (value) => setState(() => _screenReader = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sound Alerts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sound Alerts', style: AppTextStyles.labelLarge),
                                  Text(
                                    'Play audio notifications for important events',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Semantics(
                                label: 'Sound alerts toggle',
                                button: true,
                                enabled: true,
                                toggled: _soundAlerts,
                                onTap: () => setState(() => _soundAlerts = !_soundAlerts),
                                child: Switch(
                                  value: _soundAlerts,
                                  onChanged: (value) => setState(() => _soundAlerts = value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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