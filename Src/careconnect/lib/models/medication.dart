class Medication {
  final String id;
  final String name;
  final String dose;
  final String schedule;
  final List<String> times;
  final bool taken;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    required this.times,
    this.taken = false,
  });

  Medication copyWith({bool? taken}) {
    return Medication(
      id: id,
      name: name,
      dose: dose,
      schedule: schedule,
      times: times,
      taken: taken ?? this.taken,
    );
  }
}
