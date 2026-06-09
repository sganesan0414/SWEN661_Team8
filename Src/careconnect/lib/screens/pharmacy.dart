import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../models/medication.dart';
import '../providers/medications_provider.dart';

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationsProvider);

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledBackButton(
                            label: 'Dashboard',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 16),
                          Text('My Pharmacies', style: AppTextStyles.displayLarge),
                          const SizedBox(height: 4),
                          Text(
                            '${medState.medications.length} active prescriptions',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 24),

                          Text('Current Prescriptions', style: AppTextStyles.headlineMedium),
                          const SizedBox(height: 16),
                          ...medState.medications.map((med) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PrescriptionCard(med: med),
                          )),
                          const SizedBox(height: 24),

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
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  'Blue Cross Blue Shield',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 16),
                                Text('Member ID', style: AppTextStyles.caption),
                                const SizedBox(height: 4),
                                Text(
                                  'ABC123456789',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 12),
                                Text('Group', style: AppTextStyles.caption),
                                const SizedBox(height: 4),
                                Text(
                                  'GRP987654',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Medication med;

  const _PrescriptionCard({required this.med});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${med.name} ${med.dose}',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.local_pharmacy_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'CVS Pharmacy',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(med.schedule, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Contact Doctor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              Text(name, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Primary',
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                  onPressed: () {},
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
