import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

// ── Feedback helpers ─────────────────────────────────────────────────────────

/// Shows a snackbar using the app-wide [SnackBarThemeData].
///
/// Call sites used to style snackbars individually, so some floated with
/// rounded corners and others were square and edge-to-edge. Routing them all
/// through here keeps shape, colour and duration uniform; any remaining
/// variation is now a deliberate argument.
void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
}

/// Acknowledges a control that is intentionally not wired up yet.
///
/// Several buttons previously had `onPressed: () {}`, which left the user
/// tapping a live-looking control that silently did nothing. Saying so is a
/// better dead end than no feedback at all.
void showComingSoon(BuildContext context, String feature) {
  HapticFeedback.lightImpact();
  showAppSnackBar(context, '$feature is coming soon.');
}

// ── Interaction ──────────────────────────────────────────────────────────────

/// Briefly scales its child down while pressed.
///
/// Gives tiles and cards the same tactile response that Material's buttons get
/// for free, without changing their layout.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.large)),
    this.semanticLabel,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    // MergeSemantics folds the InkWell's tappable node into this labelled one.
    // Without it the tree holds a labelled non-tappable node beside an
    // unlabelled tappable one, which reads as an unnamed button to TalkBack.
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.semanticLabel,
        child: GestureDetector(
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: context.motion(AppDurations.fast),
            curve: AppCurves.standard,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: widget.borderRadius,
                focusColor: AppColors.primaryLight,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Navigation & orientation ─────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 10,
      ),
      child: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              screenLabel,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              semanticsLabel: 'You are here: $screenLabel',
            ),
          ),
          if (stepLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                stepLabel!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (onHome != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              button: true,
              label: 'Go to Home screen',
              child: InkWell(
                onTap: onHome,
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSizing.minTouchTarget,
                    minWidth: AppSizing.minTouchTarget,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
  final Color foregroundColor;

  const LabeledBackButton({
    super.key,
    this.label = 'Back',
    this.onPressed,
    this.foregroundColor = AppColors.textOnPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Return to $label',
      child: TextButton.icon(
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back, size: 20),
        label: Text('Return to $label', overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          minimumSize: const Size(80, AppSizing.minTouchTarget),
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
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),           activeIcon: Icon(Icons.home),           label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.medication_outlined),     activeIcon: Icon(Icons.medication),     label: 'Medications'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Appointments'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined),  activeIcon: Icon(Icons.notifications),  label: 'Reminders'),
    BottomNavigationBarItem(icon: Icon(Icons.people_outline),          activeIcon: Icon(Icons.people),         label: 'Care Team'),
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

// ── Content primitives ───────────────────────────────────────────────────────

/// A section title, so headings are spaced and styled identically everywhere.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: AppTextStyles.headlineMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Consistent empty state. Screens previously rendered bare centred text with
/// differing padding, or nothing at all.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.section,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 32, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: AppSpacing.md),
            // Counts change as the user marks things done; cross-fading the
            // number makes that update legible instead of a silent swap.
            AnimatedSwitcher(
              duration: context.motion(AppDurations.normal),
              switchInCurve: AppCurves.enter,
              switchOutCurve: AppCurves.exit,
              child: Text(
                value,
                key: ValueKey(value),
                style: AppTextStyles.headlineMedium,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      child: EntranceSlide(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.alertBg,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.alertBorder, width: 1.5),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(body, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
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
    return PressableScale(
      onTap: onTap,
      semanticLabel: label.replaceAll('\n', ' '),
      child: Container(
        height: 88, // generous touch zone
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(child: Icon(icon, color: iconColor, size: 28)),
            const SizedBox(height: AppSpacing.sm),
            ExcludeSemantics(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Medication card ──────────────────────────────────────────────────────────

/// The medication card shown on both the dashboard's Medications tab and the
/// standalone Medications screen.
///
/// These were two near-identical private classes (`_MedCard` and
/// `_MedicationCard`) that had already drifted apart: only one of them carried
/// a Semantics label, so the same card was announced differently depending on
/// how the user reached it. One implementation now serves both.
class MedicationCard extends StatelessWidget {
  final Medication med;
  final bool isCooling;
  final VoidCallback onMarkTaken;

  const MedicationCard({
    super.key,
    required this.med,
    required this.isCooling,
    required this.onMarkTaken,
  });

  Color get _accentColor => med.taken ? AppColors.success : AppColors.primary;
  Color get _bgColor => med.taken ? AppColors.successBg : AppColors.infoBg;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${med.name} ${med.dose}. Schedule: ${med.schedule}. '
          'Times: ${med.times.join(", ")}. '
          '${med.taken ? "Already taken today." : "Not yet taken."}',
      child: AnimatedContainer(
        duration: context.motion(AppDurations.normal),
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: _accentColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: context.motion(AppDurations.normal),
                        style: AppTextStyles.bodyMedium.copyWith(color: _accentColor),
                        child: Text(med.dose),
                      ),
                    ],
                  ),
                ),
                // The badge scales in so completing a dose registers as an
                // event rather than a silent repaint. It stays mounted at zero
                // scale to animate, so it is excluded from semantics — an
                // always-present "Taken" node would contradict the card label
                // above for a dose that has not been taken.
                ExcludeSemantics(
                  child: AnimatedScale(
                    scale: med.taken ? 1 : 0,
                    duration: context.motion(AppDurations.normal),
                    curve: AppCurves.emphasized,
                    child: const _TakenBadge(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _IconRow(icon: Icons.schedule, child: Text(
              med.times.join(', '),
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            )),
            const SizedBox(height: AppSpacing.xs),
            _IconRow(icon: Icons.repeat, child: Text(med.schedule, style: AppTextStyles.bodyMedium)),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: context.motion(AppDurations.normal),
              switchInCurve: AppCurves.enter,
              switchOutCurve: AppCurves.exit,
              child: (!med.taken || isCooling)
                  ? Semantics(
                      key: const ValueKey('mark'),
                      button: true,
                      label: 'Mark ${med.name} as taken',
                      child: ElevatedButton.icon(
                        onPressed: isCooling ? null : onMarkTaken,
                        icon: isCooling
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(isCooling ? 'Marking…' : 'Mark as Taken'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          textStyle: AppTextStyles.labelLarge,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('taken'),
                      onPressed: null,
                      icon: const Icon(Icons.check_circle, color: AppColors.success),
                      label: const Text('Taken', style: TextStyle(color: AppColors.success)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: AppColors.success),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TakenBadge extends StatelessWidget {
  const _TakenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Taken',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A muted leading icon paired with content — the repeated
/// "icon + 6pt gap + text" row used across cards.
class _IconRow extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _IconRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(child: Icon(icon, size: 16, color: AppColors.textMuted)),
        const SizedBox(width: 6),
        Flexible(child: child),
      ],
    );
  }
}
