import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/care_team_member.dart';

class CareTeamState {
  final List<CareTeamMember> members;

  const CareTeamState({this.members = const []});

  CareTeamState copyWith({List<CareTeamMember>? members}) {
    return CareTeamState(members: members ?? this.members);
  }

  int get emergencyContactCount =>
      members.where((m) => m.isEmergencyContact).length;
}

class CareTeamNotifier extends Notifier<CareTeamState> {
  @override
  CareTeamState build() => CareTeamState(members: _mockMembers);

  void addMember(CareTeamMember member) {
    state = state.copyWith(members: [...state.members, member]);
  }

  void removeMember(String id) {
    state = state.copyWith(
      members: state.members.where((m) => m.id != id).toList(),
    );
  }
}

final _mockMembers = const [
  CareTeamMember(
    id: 'ct1',
    name: 'Dr. Sarah Johnson',
    role: 'Primary Care Physician',
    phone: '(555) 123-4567',
    email: 'sjohnson@citymedical.com',
    isEmergencyContact: true,
  ),
  CareTeamMember(
    id: 'ct2',
    name: 'Patricia Williams',
    role: 'Registered Nurse',
    phone: '(555) 234-5678',
    email: 'pwilliams@citymedical.com',
  ),
  CareTeamMember(
    id: 'ct3',
    name: 'Dr. Michael Chen',
    role: 'Cardiologist',
    phone: '(555) 345-6789',
    email: 'mchen@heartinstitute.com',
  ),
];

final careTeamProvider =
    NotifierProvider<CareTeamNotifier, CareTeamState>(CareTeamNotifier.new);
