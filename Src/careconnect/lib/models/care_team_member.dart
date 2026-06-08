class CareTeamMember {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final bool isEmergencyContact;

  const CareTeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.isEmergencyContact = false,
  });
}
