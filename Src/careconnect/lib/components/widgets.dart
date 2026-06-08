import 'package:careconnect/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContextBar extends StatelessWidget {
  final String screenLabel;
  final String? stepLabel;   
  final VoidCallback? onHome;

  const ContextBar({
    super.key,
    required this.screenLabel,
    this.stepLabel,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              screenLabel,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              semanticsLabel: 'You are here: $screenLabel',
            ),
          ),
          if (stepLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stepLabel!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onHome != null) ...[
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Go to Home screen',
              child: InkWell(
                onTap: onHome,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text('Home', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LabeledBackButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const LabeledBackButton({
    super.key,
    this.label = 'Back',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go back to $label',
      child: TextButton.icon(
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back, size: 20),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          minimumSize: const Size(48, 48), // WCAG touch target
        ),
      ),
    );
  }
}

class CareConnectBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CareConnectBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),     activeIcon: Icon(Icons.home),        label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.medication_outlined),activeIcon: Icon(Icons.medication), label: 'Medications'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Appointments'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Reminders'),
    BottomNavigationBarItem(icon: Icon(Icons.people_outline),    activeIcon: Icon(Icons.people),      label: 'Care Team'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: _items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      backgroundColor: AppColors.surface,
      selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: AppTextStyles.caption,
      showSelectedLabels: true,
      showUnselectedLabels: true, // STML #3: labels always visible
      elevation: 8,
      iconSize: 26,
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value${subtitle != null ? ", $subtitle" : ""}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodyMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: AppTextStyles.caption.copyWith(color: AppColors.success)),
            ],
          ],
        ),
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const AlertBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.alertBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.alertBorder, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.warning),
                foregroundColor: AppColors.warning,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 88, // generous touch zone
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}