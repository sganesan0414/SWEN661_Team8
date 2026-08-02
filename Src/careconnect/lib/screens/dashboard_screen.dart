import 'package:careconnect/screens/user_profile.dart';
import 'package:careconnect/screens/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/account_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/medications_provider.dart';
import '../models/appointment.dart';
import '../utils/formatting.dart';
import 'appointments_screen.dart';
import 'care_team_screen.dart';
import 'health_metrics_screen.dart';
import 'health_reports_screen.dart';
import 'login_screen.dart';
import 'pharmacy.dart';
import 'reminders.dart';

/// Gives descendants access to the dashboard's navigation actions.
///
/// The tabs previously reached their host with
/// `context.findAncestorStateOfType<_DashboardScreenState>()` and then called
/// its private methods — which silently no-ops if the widget is ever used
/// outside a dashboard, and couples every child to the parent's private API.
/// An InheritedWidget makes the dependency explicit and fails loudly instead.
class DashboardScope extends InheritedWidget {
  final ValueChanged<int> selectTab;
  final VoidCallback openProfile;

  const DashboardScope({
    super.key,
    required this.selectTab,
    required this.openProfile,
    required super.child,
  });

  static DashboardScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DashboardScope>();
    assert(scope != null, 'No DashboardScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(DashboardScope oldWidget) => false;
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = 0;

  static const _appBarTitles = [
    'CareConnect',
    'My Medications',
    'Appointments',
    'Reminders',
    'Care Team',
  ];

  static const _contextLabels = [
    'Home - Daily Overview',
    'Home › My Medications',
    'Home › Appointments',
    'Home › Reminders',
    'Home › Care Team',
  ];

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _navIndex = index);
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserProfileScreen()));
  }

  void _signOut() {
    ref.read(accountProvider.notifier).signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScope(
      selectTab: _onNavTap,
      openProfile: _openProfile,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_appBarTitles[_navIndex]),
          actions: [
            Semantics(
              button: true,
              label: 'Open settings',
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: _openSettings,
                tooltip: 'Open settings',
              ),
            ),
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            ContextBar(screenLabel: _contextLabels[_navIndex]),
            Expanded(
              // IndexedStack keeps each tab's local state (search text, the
              // reminders screen's hidden/disabled sets) alive across switches;
              // _TabTransition supplies the motion the stack itself cannot.
              child: _TabTransition(
                index: _navIndex,
                child: IndexedStack(
                  index: _navIndex,
                  children: const [
                    _HomeTab(),
                    _MedicationsTab(),
                    _AppointmentsTab(),
                    _RemindersTab(),
                    _CareTeamTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CareConnectBottomNav(
          currentIndex: _navIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

/// Replays a short fade-and-lift whenever [index] changes, without rebuilding
/// [child] — so the tab bodies underneath keep their state.
class _TabTransition extends StatefulWidget {
  final int index;
  final Widget child;

  const _TabTransition({required this.index, required this.child});

  @override
  State<_TabTransition> createState() => _TabTransitionState();
}

class _TabTransitionState extends State<_TabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.normal,
    value: 1,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.enter,
  );

  @override
  void didUpdateWidget(covariant _TabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      if (context.reduceMotion) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      // Never fully transparent: the outgoing tab would flash the background.
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_curve),
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - _curve.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ── Tab 0: Home ──────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptState = ref.watch(appointmentsProvider);
    final medState = ref.watch(medicationsProvider);
    final account = ref.watch(accountProvider);
    final scope = DashboardScope.of(context);
    final displayName = account.displayName.isEmpty
        ? 'there'
        : account.displayName;

    final now = DateTime.now();
    final upcomingAppt = apptState.upcoming.isNotEmpty
        ? apptState.upcoming.first
        : null;
    final pendingMeds = medState.medications
        .where((m) => !m.taken)
        .take(3)
        .toList();

    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The hero panel and quick actions are above the fold and deliberately
          // not faded in: content that is on screen at first paint has to be
          // legible at first paint, and a fade would put it below the required
          // contrast ratio for the length of the entrance.
          _HeroPanel(
            displayName: displayName,
            now: now,
            medState: medState,
            upcomingAppt: upcomingAppt,
            onOpenProfile: scope.openProfile,
          ),
          const SizedBox(height: AppSpacing.xxl),

          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: [
              QuickActionTile(
                icon: Icons.medication_outlined,
                iconColor: AppColors.primary,
                label: 'My\nMedications',
                onTap: () => scope.selectTab(1),
              ),
              QuickActionTile(
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.appointment,
                label: 'Appointments',
                onTap: () => scope.selectTab(2),
              ),
              QuickActionTile(
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFB0193C),
                label: 'Health\nMetrics',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HealthMetricsScreen(),
                  ),
                ),
              ),
              QuickActionTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.success,
                label: 'Reports',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HealthReportsScreen(),
                  ),
                ),
              ),
              QuickActionTile(
                // Was Icons.description_outlined, identical to Reports above —
                // two different destinations shared one glyph.
                icon: Icons.local_pharmacy_outlined,
                iconColor: const Color(0xFF816FC9),
                label: 'Pharmacy',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          AlertBanner(
            icon: Icons.warning_amber_rounded,
            title: 'Refill Reminder',
            body:
                'Atorvastatin has only 2 refills remaining. Request a refill soon.',
            actionLabel: 'Request Refill',
            onAction: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PharmacyScreen())),
          ),
          const SizedBox(height: AppSpacing.xxl),

          SectionHeader(
            title: 'Upcoming Medications',
            trailing: TextButton(
              onPressed: () => scope.selectTab(1),
              child: const Text('View All'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (pendingMeds.isEmpty)
            const EmptyState(
              icon: Icons.check_circle_outline,
              message: 'All medications taken for today.',
            )
          else
            ...pendingMeds.asMap().entries.map(
              (entry) => EntranceSlide(
                index: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UpcomingMedRow(
                    name: entry.value.name,
                    dose: entry.value.dose,
                    time: entry.value.times.isNotEmpty
                        ? entry.value.times.first
                        : '',
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),

          const SectionHeader(title: 'Next Appointment'),
          const SizedBox(height: AppSpacing.md),
          if (upcomingAppt != null)
            EntranceSlide(
              child: _AppointmentCard(
                doctorName: upcomingAppt.doctorName,
                examType: upcomingAppt.specialty,
                date: formatLongDate(upcomingAppt.dateTime),
                time: formatTime(upcomingAppt.dateTime),
                onViewAll: () => scope.selectTab(2),
              ),
            )
          else
            const EmptyState(
              icon: Icons.event_available_outlined,
              message: 'No upcoming appointments.',
            ),
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String displayName;
  final DateTime now;
  final MedicationsState medState;
  final Appointment? upcomingAppt;
  final VoidCallback onOpenProfile;

  const _HeroPanel({
    required this.displayName,
    required this.now,
    required this.medState,
    required this.upcomingAppt,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final total = medState.medications.length;
    // Was hard-coded to "94%" while sitting between two live figures, so the
    // panel implied a real adherence reading that never moved. Derived from
    // today's doses instead, and relabelled to say which day it describes.
    final adherence = total == 0
        ? 0
        : ((medState.takenCount / total) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: 'Open profile for $displayName',
            child: InkWell(
              onTap: onOpenProfile,
              borderRadius: BorderRadius.circular(AppRadius.small),
              focusColor: Colors.white24,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizing.minTouchTarget,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // Was always "Good Morning", including at midnight.
                    '${greetingForHour(now.hour)}, $displayName',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatWeekdayDate(now),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Expanded rather than a LayoutBuilder-computed fixed width: the old
          // `(maxWidth - 16) / 3` ignored the outer padding at large text
          // scales and pushed the row into an overflow.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MiniStatCard(
                    value: '${medState.takenCount}/$total',
                    label: 'Medications\nToday',
                    icon: Icons.medication,
                    iconColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MiniStatCard(
                    value: '$adherence%',
                    label: "Today's\nAdherence",
                    icon: Icons.trending_up,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MiniStatCard(
                    value: upcomingAppt == null
                        ? 'None'
                        : '${shortMonthName(upcomingAppt!.dateTime.month)} ${upcomingAppt!.dateTime.day}',
                    label: 'Next\nAppointment',
                    icon: Icons.calendar_today,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Medications ───────────────────────────────────────────────────────

class _MedicationsTab extends ConsumerStatefulWidget {
  const _MedicationsTab();

  @override
  ConsumerState<_MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends ConsumerState<_MedicationsTab> {
  final Map<String, bool> _cooling = {};

  Future<void> _markTaken(String id, String name) async {
    if (_cooling[id] == true) return;
    HapticFeedback.mediumImpact();
    setState(() => _cooling[id] = true);
    ref.read(medicationsProvider.notifier).markTaken(id);

    if (!mounted) return;
    showAppSnackBar(
      context,
      '$name marked as taken',
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          HapticFeedback.lightImpact();
          ref.read(medicationsProvider.notifier).undoTaken(id);
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _cooling[id] = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationsProvider);
    final filtered = state.filtered;

    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Search medications',
            child: TextField(
              onChanged: (v) =>
                  ref.read(medicationsProvider.notifier).setSearchQuery(v),
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search medications…',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref
                            .read(medicationsProvider.notifier)
                            .setSearchQuery(''),
                        tooltip: 'Clear search',
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.medication,
                    iconColor: AppColors.primary,
                    value: '${state.medications.length}',
                    label: 'Medications',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    value: '${state.takenCount}',
                    label: 'Taken Today',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.schedule,
                    iconColor: AppColors.warning,
                    value: '${state.upcomingCount}',
                    label: 'Upcoming',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.search_off_outlined,
              message: 'No medications match your search.',
            )
          else
            ...filtered.asMap().entries.map(
              (entry) => EntranceSlide(
                index: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: MedicationCard(
                    med: entry.value,
                    isCooling: _cooling[entry.value.id] == true,
                    onMarkTaken: () =>
                        _markTaken(entry.value.id, entry.value.name),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Tab 2: Appointments ──────────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) => const AppointmentsScreen();
}

// ── Tab 3: Reminders ─────────────────────────────────────────────────────────

class _RemindersTab extends StatelessWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context) {
    return RemindersScreen(
      onBack: () => DashboardScope.of(context).selectTab(0),
    );
  }
}

// ── Tab 4: Care Team ─────────────────────────────────────────────────────────

class _CareTeamTab extends StatelessWidget {
  const _CareTeamTab();

  @override
  Widget build(BuildContext context) => const CareTeamScreen();
}

// ── Shared sub-widgets ───────────────────────────────────────────────────────

class _UpcomingMedRow extends StatelessWidget {
  final String name, dose, time;
  const _UpcomingMedRow({
    required this.name,
    required this.dose,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name, $dose, due at $time',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.warningBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.labelLarge),
                    Text(dose, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    'Due soon',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
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

class _AppointmentCard extends StatelessWidget {
  final String doctorName, examType, date, time;
  final VoidCallback onViewAll;

  const _AppointmentCard({
    required this.doctorName,
    required this.examType,
    required this.date,
    required this.time,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Upcoming appointment: $doctorName, $examType, on $date at $time',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.infoBg,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctorName, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(examType, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(date, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(time, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onViewAll,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('View All Appointments'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // label may contain '\n' — flatten for screen reader
    final flatLabel = label.replaceAll('\n', ' ');
    return Semantics(
      label: '$flatLabel: $value',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedSwitcher(
                duration: context.motion(AppDurations.normal),
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Colors.white rather than white70: white70 on the semi-transparent
              // blue container yields ~3.75:1, below the 4.5:1 WCAG AA threshold
              // for 13sp text.
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
