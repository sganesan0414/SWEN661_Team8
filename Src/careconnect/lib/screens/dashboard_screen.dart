import 'package:careconnect/screens/user_profile.dart';
import 'package:careconnect/screens/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/account_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/medications_provider.dart';
import '../models/medication.dart';
import 'appointments_screen.dart';
import 'care_team_screen.dart';
import 'health_metrics_screen.dart';
import 'health_reports_screen.dart';
import 'login_screen.dart';
import 'medications_screen.dart';
import 'pharmacy.dart';
import 'reminders.dart';

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
    HapticFeedback.selectionClick();
    if (index == 5) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
    } else if (index == 6) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    } else {
      setState(() => _navIndex = index);
    }
  }

  void _signOut() {
    ref.read(accountProvider.notifier).signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_appBarTitles[_navIndex]),
        actions: [
          Semantics(
            button: true,
            label: 'Sign out',
            child: TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
              label: const Text('Sign out', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ContextBar(screenLabel: _contextLabels[_navIndex]),
          Expanded(
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
        ],
      ),
      bottomNavigationBar: CareConnectBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
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
    final displayName = account.displayName.isEmpty ? 'there' : account.displayName;

    final now = DateTime.now();
    final upcomingAppt = apptState.upcoming.isNotEmpty ? apptState.upcoming.first : null;
    final todayLabel = _todayLabel(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, $displayName',
                  style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  todayLabel,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constraints) {
                  final w = (constraints.maxWidth - 16) / 3;
                  return Row(
                    children: [
                      _MiniStatCard(
                        value: '${medState.takenCount}/${medState.medications.length}',
                        label: 'Medications\nToday',
                        icon: Icons.medication,
                        iconColor: AppColors.accent,
                        width: w,
                      ),
                      const SizedBox(width: 8),
                      _MiniStatCard(
                        value: '94%',
                        label: 'Adherence\nRate',
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFF1A7A4A),
                        width: w,
                      ),
                      const SizedBox(width: 8),
                      _MiniStatCard(
                        value: upcomingAppt != null
                            ? '${_shortMonth(upcomingAppt.dateTime.month)} ${upcomingAppt.dateTime.day}'
                            : 'None',
                        label: 'Next\nAppointment',
                        icon: Icons.calendar_today,
                        iconColor: AppColors.accent,
                        width: w,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Quick Actions', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
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
                onTap: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onNavTap(1);
                },
              ),
              QuickActionTile(
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFF7B3FA0),
                label: 'Appointments',
                onTap: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onNavTap(2);
                },
              ),
              QuickActionTile(
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFB0193C),
                label: 'Health\nMetrics',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HealthMetricsScreen()),
                ),
              ),
              QuickActionTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF1A7A4A),
                label: 'Reports',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HealthReportsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          AlertBanner(
            icon: Icons.warning_amber_rounded,
            title: 'Refill Reminder',
            body: 'Atorvastatin has only 2 refills remaining. Request a refill soon.',
            actionLabel: 'Request Refill',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PharmacyScreen()),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Medications', style: AppTextStyles.headlineMedium),
              TextButton(
                onPressed: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onNavTap(1);
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...medState.medications
              .where((m) => !m.taken)
              .take(3)
              .map((med) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UpcomingMedRow(name: med.name, dose: med.dose, time: med.times.first),
                  )),
          const SizedBox(height: 24),

          Text('Next Appointment', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          if (upcomingAppt != null)
            _AppointmentCard(
              doctorName: upcomingAppt.doctorName,
              examType: upcomingAppt.specialty,
              date: '${_monthName(upcomingAppt.dateTime.month)} ${upcomingAppt.dateTime.day}, ${upcomingAppt.dateTime.year}',
              time: _formatTime(upcomingAppt.dateTime),
            )
          else
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(child: Text('No upcoming appointments.', style: AppTextStyles.bodyMedium)),
            ),
          const SizedBox(height: 32),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name marked as taken'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(medicationsProvider.notifier).undoTaken(id);
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Search medications',
            child: TextField(
              onChanged: (v) => ref.read(medicationsProvider.notifier).setSearchQuery(v),
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search medications…',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref.read(medicationsProvider.notifier).setSearchQuery(''),
                        tooltip: 'Clear search',
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.medication, iconColor: AppColors.primary, value: '${state.medications.length}', label: 'Total Medications')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.check_circle_outline, iconColor: AppColors.success, value: '${state.takenCount}', label: 'Taken Today')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.schedule, iconColor: AppColors.warning, value: '${state.upcomingCount}', label: 'Upcoming')),
            ],
          ),
          const SizedBox(height: 24),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No medications match your search.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              ),
            )
          else
            ...filtered.map((med) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MedCard(
                    med: med,
                    isCooling: _cooling[med.id] == true,
                    onMarkTaken: () => _markTaken(med.id, med.name),
                  ),
                )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final bool isCooling;
  final VoidCallback onMarkTaken;
  const _MedCard({required this.med, required this.isCooling, required this.onMarkTaken});

  Color get _borderColor => med.taken ? AppColors.success : AppColors.primary;
  Color get _bgColor => med.taken ? AppColors.successBg : AppColors.infoBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.5),
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
                    Text(med.dose, style: AppTextStyles.bodyMedium.copyWith(color: _borderColor)),
                  ],
                ),
              ),
              if (med.taken)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('Taken', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(med.times.join(', '), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.repeat, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(med.schedule, style: AppTextStyles.bodyMedium),
          ]),
          const SizedBox(height: 14),
          if (!med.taken)
            ElevatedButton.icon(
              onPressed: isCooling ? null : onMarkTaken,
              icon: isCooling
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(isCooling ? 'Marking…' : 'Mark as Taken'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check_circle, color: AppColors.success),
              label: const Text('Taken', style: TextStyle(color: AppColors.success)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
  Widget build(BuildContext context) => const RemindersScreen();
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
  const _UpcomingMedRow({required this.name, required this.dose, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: AppColors.warningBg, shape: BoxShape.circle),
            child: const Icon(Icons.schedule, color: AppColors.warning, size: 20),
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
              Text(time, style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning)),
              Text('Due soon', style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName, examType, date, time;
  const _AppointmentCard({required this.doctorName, required this.examType, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(doctorName, style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(examType, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(date, style: AppTextStyles.bodyMedium),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(time, style: AppTextStyles.bodyMedium),
          ]),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              final state = context.findAncestorStateOfType<_DashboardScreenState>();
              state?._onNavTap(2);
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('View All Appointments'),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;
  final double width;
  const _MiniStatCard({required this.value, required this.label, required this.icon, required this.iconColor, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

String _todayLabel(DateTime now) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}';
}

String _shortMonth(int month) {
  const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return names[month];
}

String _monthName(int month) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return names[month];
}

String _formatTime(DateTime dt) {
  final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final m = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}
