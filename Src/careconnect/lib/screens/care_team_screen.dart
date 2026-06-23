import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/care_team_member.dart';
import '../providers/care_team_provider.dart';

class CareTeamScreen extends ConsumerWidget {
  const CareTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careTeamProvider);
    final members = state.members;
    final emergencyCount = state.emergencyContactCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: StatCard(icon: Icons.people, iconColor: AppColors.primary, value: '${members.length}', label: 'Total Members')),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.emergency, iconColor: Colors.red, value: '$emergencyCount', label: 'Emergency Contacts')),
              ],
            ),
          ),
          if (emergencyCount == 0) ...[
            const SizedBox(height: 16),
            AlertBanner(
              icon: Icons.warning_amber_rounded,
              title: 'No Emergency Contact',
              body: 'Please add an emergency contact to ensure you can be reached in critical situations.',
              actionLabel: 'Add Emergency Contact',
              onAction: () {},
            ),
          ],
          const SizedBox(height: 20),
          Text('Care Team Members', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...members.map((member) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CareTeamMemberCard(
                  member: member,
                  onRemove: () {
                    HapticFeedback.mediumImpact();
                    ref.read(careTeamProvider.notifier).removeMember(member.id);
                  },
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CareTeamMemberCard extends StatelessWidget {
  final CareTeamMember member;
  final VoidCallback onRemove;

  const _CareTeamMemberCard({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final initials = member.name.split(' ').map((w) => w[0]).take(2).join();

    return Semantics(
      label: '${member.name}, ${member.role}${member.isEmergencyContact ? ", Emergency Contact" : ""}',
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: member.isEmergencyContact ? Colors.red.withValues(alpha: 0.4) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(member.name, style: AppTextStyles.labelLarge)),
                          if (member.isEmergencyContact)
                            ExcludeSemantics(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Text('Emergency', style: AppTextStyles.caption.copyWith(color: Colors.red, fontWeight: FontWeight.w700)),
                              ),
                            ),
                        ],
                      ),
                      Text(member.role, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ContactChip(
                  icon: Icons.phone_outlined,
                  label: member.phone,
                  semanticLabel: 'Phone: ${member.phone}',
                ),
                const SizedBox(width: 10),
                _ContactChip(
                  icon: Icons.email_outlined,
                  label: member.email,
                  semanticLabel: 'Email: ${member.email}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Manage access for ${member.name}',
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text('Manage Access'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String semanticLabel;

  const _ContactChip({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 14, color: AppColors.textMuted)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                semanticsLabel: semanticLabel,
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
