import 'package:careconnect/screens/user_profile.dart';
import 'package:careconnect/screens/user_settings.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import 'medications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  // TODO: Fake data
  static const _userName = 'Siva';
  static const _todayLabel = 'Tuesday, June 3';

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    // TODO: we need to  use go_router / Navigator to push named routes
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MedicationsScreen()),
      );
    }
    else if (index == 5) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
    }
    else if (index == 6) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MemoGuard'),
        actions: [
          Semantics(
            button: true,
            label: 'Sign out',
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
              label: const Text('Sign out', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ContextBar(
            screenLabel: 'Home — Daily Overview',
          ),
          Expanded(
            child: SingleChildScrollView(
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
                          'Good Morning, $_userName',
                          style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _todayLabel,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        // ── Stat cards ──────────────────────────────────────
                        LayoutBuilder(builder: (context, constraints) {
                          final w = (constraints.maxWidth - 16) / 3;
                          return Row(
                            children: [
                              _MiniStatCard(value: '5/6', label: 'Medications\nToday', icon: Icons.medication, iconColor: AppColors.accent, width: w),
                              const SizedBox(width: 8),
                              _MiniStatCard(value: '94%', label: 'Adherence\nRate', icon: Icons.trending_up, iconColor: const Color(0xFF1A7A4A), width: w),
                              const SizedBox(width: 8),
                              _MiniStatCard(value: 'Jun 15', label: 'Next\nAppointment', icon: Icons.calendar_today, iconColor: AppColors.accent, width: w),
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
                        onTap: () => _onNavTap(1),
                      ),
                      QuickActionTile(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFF7B3FA0),
                        label: 'Appointments',
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFFB85C00),
                        label: 'Reminders',
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: Icons.favorite_outline,
                        iconColor: const Color(0xFFB0193C),
                        label: 'Health\nMetrics',
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFFB0193C),
                        label: 'Profile',
                        onTap: () => _onNavTap(5),
                      ),
                      QuickActionTile(
                        icon: Icons.settings_outlined,
                        iconColor: AppColors.textMuted,
                        label: 'Settings',
                        onTap: () => _onNavTap(6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  AlertBanner(
                    icon: Icons.warning_amber_rounded,
                    title: 'Refill Reminder',
                    body: 'Atorvastatin has only 2 refills remaining. Request a refill soon.',
                    actionLabel: 'Request Refill',
                    onAction: () {},
                  ),
                  const SizedBox(height: 24),

                  // ── Upcoming Medications ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Medications', style: AppTextStyles.headlineMedium),
                      TextButton(
                        onPressed: () => _onNavTap(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._upcomingMeds.map((med) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UpcomingMedRow(med: med),
                  )),
                  const SizedBox(height: 24),

                  // ── Next appointment card ─────────────────────────────────
                  Text('Next Appointment', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 12),
                  _AppointmentCard(
                    doctorName: 'Dr. Sarah Johnson',
                    examType: 'Annual Physical Exam',
                    date: 'June 15, 2026',
                    time: '10:00 AM',
                  ),
                  const SizedBox(height: 32),
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
    );
  }
}

class _MedData {
  final String name, dose, time;
  final bool dueSoon;
  const _MedData({required this.name, required this.dose, required this.time, this.dueSoon = false});
}

const _upcomingMeds = [
  _MedData(name: 'Lisinopril', dose: '10 mg', time: '8:00 AM', dueSoon: true),
  _MedData(name: 'Metformin', dose: '500 mg', time: '8:00 AM', dueSoon: true),
  _MedData(name: 'Aspirin', dose: '81 mg', time: '8:00 AM', dueSoon: true),
];

class _UpcomingMedRow extends StatelessWidget {
  final _MedData med;
  const _UpcomingMedRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${med.name} ${med.dose} — due at ${med.time}${med.dueSoon ? ", due soon" : ""}',
      child: Container(
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
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: AppTextStyles.labelLarge),
                  Text(med.dose, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(med.time, style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning)),
                if (med.dueSoon)
                  Text('Due soon', style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName, examType, date, time;
  const _AppointmentCard({required this.doctorName, required this.examType, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Next appointment: $doctorName, $examType on $date at $time',
      child: Container(
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
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
  final double width;
  const _MiniStatCard({required this.value, required this.label, required this.icon, required this.iconColor, required this.width});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Container(
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
      ),
    );
  }
}