import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/care_team_member.dart';
import '../providers/care_team_provider.dart';
import '../utils/formatting.dart';

class CareTeamScreen extends ConsumerWidget {
  const CareTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careTeamProvider);
    final members = state.members;
    final emergencyCount = state.emergencyContactCount;

    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: StatCard(icon: Icons.people, iconColor: AppColors.primary, value: '${members.length}', label: 'Total Members')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: StatCard(icon: Icons.emergency, iconColor: AppColors.danger, value: '$emergencyCount', label: 'Emergency Contacts')),
              ],
            ),
          ),
          if (emergencyCount == 0) ...[
            const SizedBox(height: AppSpacing.lg),
            AlertBanner(
              icon: Icons.warning_amber_rounded,
              title: 'No Emergency Contact',
              body: 'Please add an emergency contact to ensure you can be reached in critical situations.',
              actionLabel: 'Add Emergency Contact',
              onAction: () => showComingSoon(context, 'Adding an emergency contact'),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Care Team Members'),
          const SizedBox(height: AppSpacing.md),
          if (members.isEmpty)
            const EmptyState(
              icon: Icons.people_outline,
              message: 'No care team members yet.',
            )
          else
            ...members.asMap().entries.map((entry) => EntranceSlide(
                  index: entry.key,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _CareTeamMemberCard(
                      member: entry.value,
                      onRemove: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(careTeamProvider.notifier)
                            .removeMember(entry.value.id);
                      },
                    ),
                  ),
                )),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _CareTeamMemberCard extends StatelessWidget {
  final CareTeamMember member;
  final VoidCallback onRemove;

  const _CareTeamMemberCard({required this.member, required this.onRemove});

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          '${member.name} will no longer have access to your care information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) onRemove();
  }

  @override
  Widget build(BuildContext context) {
    // Was `member.name.split(' ').map((w) => w[0])`, which throws a RangeError
    // on an empty name or any name containing a double space, because those
    // produce empty segments with no index 0.
    final initials = initialsOf(member.name);

    return Semantics(
      label: '${member.name}, ${member.role}'
          '${member.isEmergencyContact ? ", Emergency Contact" : ""}',
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: member.isEmergencyContact
                ? AppColors.danger.withValues(alpha: 0.4)
                : AppColors.border,
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
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: AppColors.danger),
                                ),
                                child: Text('Emergency', style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700)),
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
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ContactChip(
                    icon: Icons.phone_outlined,
                    label: member.phone,
                    semanticLabel: 'Phone: ${member.phone}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ContactChip(
                    icon: Icons.email_outlined,
                    label: member.email,
                    semanticLabel: 'Email: ${member.email}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Manage access for ${member.name}',
                    child: OutlinedButton(
                      onPressed: () => showComingSoon(context, 'Managing access'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, AppSizing.minTouchTarget),
                      ),
                      child: const Text('Manage Access'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // The card already accepted an `onRemove` callback, but nothing
                // in the tree ever called it — removing a member was
                // unreachable from the UI.
                Semantics(
                  button: true,
                  label: 'Remove ${member.name} from your care team',
                  child: IconButton(
                    onPressed: () => _confirmRemove(context),
                    icon: const Icon(Icons.person_remove_outlined),
                    tooltip: 'Remove ${member.name}',
                    color: AppColors.danger,
                    constraints: const BoxConstraints(
                      minWidth: AppSizing.minTouchTarget,
                      minHeight: AppSizing.minTouchTarget,
                    ),
                  ),
                ),
              ],
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
    // Returns a plain container: it previously returned an `Expanded`, which
    // silently constrained it to Row/Column parents. The Expanded now lives at
    // the call site, where the layout decision belongs.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        children: [
          ExcludeSemantics(child: Icon(icon, size: 14, color: AppColors.textMuted)),
          const SizedBox(width: AppSpacing.xs),
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
    );
  }
}
