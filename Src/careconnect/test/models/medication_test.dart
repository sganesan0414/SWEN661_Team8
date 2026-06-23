import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/models/medication.dart';

void main() {
  group('Medication', () {
    final base = const Medication(
      id: 'm1',
      name: 'Lisinopril',
      dose: '10 mg',
      schedule: 'Daily',
      times: ['8:00 AM'],
    );

    test('copyWith overrides taken when provided', () {
      final updated = base.copyWith(taken: true);
      expect(updated.taken, isTrue);
      expect(updated.id, base.id);
      expect(updated.name, base.name);
    });

    test('copyWith keeps taken when not provided', () {
      final updated = base.copyWith();
      expect(updated.taken, base.taken);
    });
  });
}
