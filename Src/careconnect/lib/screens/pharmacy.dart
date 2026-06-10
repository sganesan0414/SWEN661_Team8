import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/medication.dart';
import '../providers/medications_provider.dart';

// ── Mock prescription extra data ─────────────────────────────────────────────

class _PrescriptionExt {
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String cost;
  final int refillsRemaining;
  final String pickupBy;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyPhone;

  const _PrescriptionExt({
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.cost,
    required this.refillsRemaining,
    required this.pickupBy,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.pharmacyPhone,
  });
}

const _extData = [
  _PrescriptionExt(
    status: 'Ready for Pickup',
    statusColor: AppColors.success,
    statusBgColor: AppColors.successBg,
    cost: '\$12.00',
    refillsRemaining: 3,
    pickupBy: 'Jun 18, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
  _PrescriptionExt(
    status: 'Being Processed',
    statusColor: AppColors.accent,
    statusBgColor: AppColors.infoBg,
    cost: '\$25.00',
    refillsRemaining: 2,
    pickupBy: 'Jun 22, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
  _PrescriptionExt(
    status: 'Refill Needed',
    statusColor: AppColors.warning,
    statusBgColor: AppColors.warningBg,
    cost: '\$10.00',
    refillsRemaining: 0,
    pickupBy: 'Jun 15, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
  _PrescriptionExt(
    status: 'Ready for Pickup',
    statusColor: AppColors.success,
    statusBgColor: AppColors.successBg,
    cost: '\$8.00',
    refillsRemaining: 5,
    pickupBy: 'Jun 20, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
  _PrescriptionExt(
    status: 'Being Processed',
    statusColor: AppColors.accent,
    statusBgColor: AppColors.infoBg,
    cost: '\$30.00',
    refillsRemaining: 1,
    pickupBy: 'Jun 25, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
  _PrescriptionExt(
    status: 'Ready for Pickup',
    statusColor: AppColors.success,
    statusBgColor: AppColors.successBg,
    cost: '\$15.00',
    refillsRemaining: 4,
    pickupBy: 'Jun 19, 2026',
    pharmacyName: 'CVS Pharmacy',
    pharmacyAddress: '123 Main Street, San Francisco, CA 94102',
    pharmacyPhone: '(555) 123-4567',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationsProvider);
    final meds = medState.medications;

    final readyCount = meds
        .asMap()
        .entries
        .where((e) => _extData[e.key % _extData.length].status == 'Ready for Pickup')
        .length;
    final processingCount = meds
        .asMap()
        .entries
        .where((e) => _extData[e.key % _extData.length].status == 'Being Processed')
        .length;
    final refillCount = meds
        .asMap()
        .entries
        .where((e) => _extData[e.key % _extData.length].status == 'Refill Needed')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Pharmacies')),
      body: Column(
        children: [
          const ContextBar(screenLabel: 'Home › Pharmacy'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledBackButton(
                            label: 'Dashboard',
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 16),
                          _buildHeader(context, meds.length),
                          const SizedBox(height: 20),
                          _buildRightPanel(readyCount, processingCount, refillCount),
                          const SizedBox(height: 24),
                          _buildPrescriptions(context, meds),
                          const SizedBox(height: 24),
                          _buildNearbyPharmacies(context),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Left column ──────────────────────────────────
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabeledBackButton(
                                label: 'Dashboard',
                                onPressed: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(height: 16),
                              _buildHeader(context, meds.length),
                              const SizedBox(height: 24),
                              _buildPrescriptions(context, meds),
                              const SizedBox(height: 24),
                              _buildNearbyPharmacies(context),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // ── Right column ─────────────────────────────────
                        Expanded(
                          flex: 1,
                          child: _buildRightPanel(readyCount, processingCount, refillCount),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Pharmacies', style: AppTextStyles.displayLarge),
        const SizedBox(height: 4),
        Text(
          '$count active prescriptions',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildPrescriptions(BuildContext context, List<Medication> meds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Prescriptions', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 16),
        ...meds.asMap().entries.map((entry) {
          final ext = _extData[entry.key % _extData.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PrescriptionCard(med: entry.value, ext: ext),
          );
        }),
      ],
    );
  }

  Widget _buildNearbyPharmacies(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nearby Pharmacies', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 16),
        const _PharmacyCard(
          name: 'CVS Pharmacy',
          isPrimary: true,
          rating: 4.5,
          address: '123 Main Street, San Francisco, CA 94102',
          distance: '0.5 miles away',
          phone: '(555) 123-4567',
          hours: 'Open until 10:00 PM',
        ),
        const SizedBox(height: 16),
        const _PharmacyCard(
          name: 'Walgreens',
          rating: 4.3,
          address: '456 Market Street, San Francisco, CA 94103',
          distance: '1.2 miles away',
          phone: '(555) 234-5678',
          hours: 'Open 24 hours',
        ),
        const SizedBox(height: 16),
        const _PharmacyCard(
          name: 'Rite Aid',
          rating: 4.1,
          address: '789 Mission Street, San Francisco, CA 94104',
          distance: '1.8 miles away',
          phone: '(555) 345-6789',
          hours: 'Open until 9:00 PM',
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRightPanel(int readyCount, int processingCount, int refillCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Primary pharmacy ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CVS Pharmacy',
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Primary',
                      style: AppTextStyles.caption.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PharmacyInfoRow(
                icon: Icons.location_on_outlined,
                text: '123 Main Street, San Francisco, CA 94102',
              ),
              const SizedBox(height: 6),
              _PharmacyInfoRow(icon: Icons.schedule, text: 'Open until 10:00 PM'),
              const SizedBox(height: 6),
              _PharmacyInfoRow(icon: Icons.phone_outlined, text: '(555) 123-4567'),
              const SizedBox(height: 6),
              _PharmacyInfoRow(icon: Icons.directions, text: '0.5 miles away'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Prescription status summary ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prescription Status',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _StatusSummaryRow(
                label: 'Ready for Pickup',
                count: readyCount,
                color: AppColors.success,
                bgColor: AppColors.successBg,
              ),
              const SizedBox(height: 10),
              _StatusSummaryRow(
                label: 'Being Processed',
                count: processingCount,
                color: AppColors.accent,
                bgColor: AppColors.infoBg,
              ),
              const SizedBox(height: 10),
              _StatusSummaryRow(
                label: 'Refill Needed',
                count: refillCount,
                color: AppColors.warning,
                bgColor: AppColors.warningBg,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Insurance info ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insurance',
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Blue Cross Blue Shield',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text('Member ID', style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                'ABC123456789',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text('Group', style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                'GRP987654',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Status summary row ───────────────────────────────────────────────────────

class _StatusSummaryRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _StatusSummaryRow({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ── Prescription card ────────────────────────────────────────────────────────

class _PrescriptionCard extends StatelessWidget {
  final Medication med;
  final _PrescriptionExt ext;

  const _PrescriptionCard({required this.med, required this.ext});

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PrescriptionDetailSheet(med: med, ext: ext),
    );
  }

  void _showDirections(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Directions to ${ext.pharmacyName}: ${ext.pharmacyAddress}'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + status badge ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${med.name} ${med.dose}',
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.local_pharmacy_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        ext.pharmacyName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ext.statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  ext.status,
                  style: AppTextStyles.caption.copyWith(
                    color: ext.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Details grid ─────────────────────────────────────────────
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _DetailChip(
                icon: Icons.attach_money,
                label: 'Cost',
                value: ext.cost,
              ),
              _DetailChip(
                icon: Icons.replay,
                label: 'Refills',
                value: ext.refillsRemaining == 0
                    ? 'None remaining'
                    : '${ext.refillsRemaining} remaining',
                valueColor: ext.refillsRemaining == 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
              _DetailChip(
                icon: Icons.event_available_outlined,
                label: 'Pick up by',
                value: ext.pickupBy,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Action buttons ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDirections(context),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Get Directions'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDetails(context),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Detail chip ───────────────────────────────────────────────────────────────

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Prescription detail bottom sheet ─────────────────────────────────────────

class _PrescriptionDetailSheet extends StatelessWidget {
  final Medication med;
  final _PrescriptionExt ext;

  const _PrescriptionDetailSheet({required this.med, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${med.name} ${med.dose}',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(med.schedule, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          _SheetRow(label: 'Status', value: ext.status, valueColor: ext.statusColor),
          const SizedBox(height: 10),
          _SheetRow(label: 'Cost per fill', value: ext.cost),
          const SizedBox(height: 10),
          _SheetRow(
            label: 'Refills remaining',
            value: ext.refillsRemaining == 0
                ? 'None — contact doctor'
                : '${ext.refillsRemaining}',
            valueColor: ext.refillsRemaining == 0 ? AppColors.warning : null,
          ),
          const SizedBox(height: 10),
          _SheetRow(label: 'Pick up by', value: ext.pickupBy),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Text('Pharmacy', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          _PharmacyInfoRow(
            icon: Icons.local_pharmacy_outlined,
            text: ext.pharmacyName,
          ),
          const SizedBox(height: 6),
          _PharmacyInfoRow(
            icon: Icons.location_on_outlined,
            text: ext.pharmacyAddress,
          ),
          const SizedBox(height: 6),
          _PharmacyInfoRow(
            icon: Icons.phone_outlined,
            text: ext.pharmacyPhone,
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SheetRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Pharmacy card ────────────────────────────────────────────────────────────

class _PharmacyCard extends StatelessWidget {
  final String name;
  final bool isPrimary;
  final double rating;
  final String address;
  final String distance;
  final String phone;
  final String hours;

  const _PharmacyCard({
    required this.name,
    this.isPrimary = false,
    required this.rating,
    required this.address,
    required this.distance,
    required this.phone,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.border,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.titleLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              if (isPrimary)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Primary',
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < rating.toInt() ? Icons.star : Icons.star_outline,
                  size: 16,
                  color: const Color(0xFFFFA500),
                ),
              ),
              const SizedBox(width: 8),
              Text('$rating', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          _PharmacyInfoRow(icon: Icons.location_on_outlined, text: address),
          const SizedBox(height: 8),
          _PharmacyInfoRow(icon: Icons.directions, text: distance),
          const SizedBox(height: 8),
          _PharmacyInfoRow(icon: Icons.phone_outlined, text: phone),
          const SizedBox(height: 8),
          _PharmacyInfoRow(icon: Icons.schedule, text: hours),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Directions to $name: $address'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PharmacyInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PharmacyInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
