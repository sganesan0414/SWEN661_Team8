enum AppointmentStatus { upcoming, completed, cancelled }

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final String notes;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.location,
    this.notes = '',
    this.status = AppointmentStatus.upcoming,
  });

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? dateTime,
  }) {
    return Appointment(
      id: id,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime ?? this.dateTime,
      location: location,
      notes: notes,
      status: status ?? this.status,
    );
  }
}
