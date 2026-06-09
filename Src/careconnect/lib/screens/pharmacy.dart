import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/widgets.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CareConnect'),
        actions: [
          Semantics(
            button: true,
            label: 'Sign out',
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
              label: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ContextBar(
            screenLabel: 'Pharmacy — My Pharmacies',
          ),
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
                          Text('1 prescription ready + 1 need refill',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 24),

                          // Current Prescriptions
                          Text('Current Prescriptions', style: AppTextStyles.headlineMedium),
                          const SizedBox(height: 16),
                          _PrescriptionCard(
                            name: 'Atorvastatin 20mg',
                            pharmacy: 'CVS Pharmacy',
                            pickupDate: 'June 10, 2026',
                            refills: '0 remaining',
                            cost: '\$18.75',
                            status: 'Refill Needed',
                            statusColor: AppColors.error,
                            showRefillWarning: true,
                          ),
                          const SizedBox(height: 16),
                          _PrescriptionCard(
                            name: 'Lisinopril 10mg',
                            pharmacy: 'CVS Pharmacy',
                            pickupDate: 'June 5, 2026',
                            refills: '2 remaining',
                            cost: '\$12.50',
                            status: 'Ready for Pickup',
                            statusColor: const Color(0xFF1A7A4A),
                            showRefillWarning: false,
                          ),
                          const SizedBox(height: 24),

                          // Nearby Pharmacies
                          Text('Nearby Pharmacies', style: AppTextStyles.headlineMedium),
                          const SizedBox(height: 16),
                          _PharmacyCard(
                            name: 'CVS Pharmacy',
                            isPrimary: true,
                            rating: 4.5,
                            address: '123 Main Street, San Francisco, CA 94102',
                            distance: '0.5 miles away',
                            phone: '(555) 123-4567',
                            hours: 'Open until 10:00 PM',
                          ),
                          const SizedBox(height: 16),
                          _PharmacyCard(
                            name: 'Walgreens',
                            rating: 4.3,
                            address: '456 Market Street, San Francisco, CA 94103',
                            distance: '1.2 miles away',
                            phone: '(555) 234-5678',
                            hours: 'Open 24 hours',
                          ),
                          const SizedBox(height: 16),
                          _PharmacyCard(
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
                          // Insurance Info Card
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
                                Text('Blue Cross Blue Shield',
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                Text('Member ID', style: AppTextStyles.labelSmall),
                                const SizedBox(height: 4),
                                Text('ABC123456789',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                Text('Group', style: AppTextStyles.labelSmall),
                                const SizedBox(height: 4),
                                Text('GRP987654',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
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
  final String name;
  final String pharmacy;
  final String pickupDate;
  final String refills;
  final String cost;
  final String status;
  final Color statusColor;
  final bool showRefillWarning;

  const _PrescriptionCard({
    required this.name,
    required this.pharmacy,
    required this.pickupDate,
    required this.refills,
    required this.cost,
    required this.status,
    required this.statusColor,
    required this.showRefillWarning,
  });

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(pharmacy,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoColumn(label: 'Pickup By', value: pickupDate),
              _InfoColumn(label: 'Refills', value: refills),
              _InfoColumn(label: 'Cost', value: cost),
            ],
          ),
          if (showRefillWarning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Refill Required',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          )),
                        const SizedBox(height: 2),
                        Text('No refills remaining. Contact your doctor for a new prescription.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
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
                  child: Text('Primary',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < rating.toInt() ? Icons.star : Icons.star_outline,
                size: 16,
                color: const Color(0xFFFFA500),
              )),
              const SizedBox(width: 8),
              Text('${rating}', style: AppTextStyles.labelSmall),
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
          child: Text(text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
