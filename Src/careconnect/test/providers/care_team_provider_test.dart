import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect/providers/care_team_provider.dart';
import 'package:careconnect/models/care_team_member.dart';

void main() {
  group('CareTeamNotifier', () {
    test('initial state has 3 mock members', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(careTeamProvider).members.length, 3);
    });

    test('emergencyContactCount counts correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(careTeamProvider).emergencyContactCount, 1);
    });

    test('addMember appends to list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(careTeamProvider.notifier).addMember(const CareTeamMember(
        id: 'new1', name: 'New Doctor', role: 'Specialist',
        phone: '555-9999', email: 'new@test.com',
      ));
      expect(container.read(careTeamProvider).members.length, 4);
    });

    test('removeMember removes from list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(careTeamProvider.notifier).removeMember('ct1');
      expect(container.read(careTeamProvider).members.length, 2);
      expect(container.read(careTeamProvider).members.any((m) => m.id == 'ct1'), isFalse);
    });
  });
}
