import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/providers/medications_provider.dart';

void main() {
  group('MedicationsNotifier', () {
    test('initial state has 6 medications', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(medicationsProvider).medications.length, 6);
    });

    test('markTaken sets medication taken', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(medicationsProvider.notifier).markTaken('1');
      final med = container.read(medicationsProvider).medications.firstWhere((m) => m.id == '1');
      expect(med.taken, isTrue);
    });

    test('undoTaken resets medication', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(medicationsProvider.notifier).markTaken('1');
      container.read(medicationsProvider.notifier).undoTaken('1');
      final med = container.read(medicationsProvider).medications.firstWhere((m) => m.id == '1');
      expect(med.taken, isFalse);
    });

    test('setSearchQuery filters medications', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(medicationsProvider.notifier).setSearchQuery('Lisinopril');
      final filtered = container.read(medicationsProvider).filtered;
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Lisinopril');
    });

    test('takenCount counts taken meds', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Metformin and Levothyroxine start as taken
      expect(container.read(medicationsProvider).takenCount, 2);
    });
  });
}
