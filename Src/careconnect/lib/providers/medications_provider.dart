import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';

class MedicationsState {
  final List<Medication> medications;
  final String searchQuery;

  const MedicationsState({
    this.medications = const [],
    this.searchQuery = '',
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    String? searchQuery,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Medication> get filtered {
    if (searchQuery.isEmpty) return medications;
    return medications
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  int get takenCount => medications.where((m) => m.taken).length;
  int get upcomingCount => medications.where((m) => !m.taken).length;
}

class MedicationsNotifier extends Notifier<MedicationsState> {
  @override
  MedicationsState build() => const MedicationsState(medications: _mockMeds);

  void markTaken(String id) {
    state = state.copyWith(
      medications: state.medications
          .map((m) => m.id == id ? m.copyWith(taken: true) : m)
          .toList(),
    );
  }

  void undoTaken(String id) {
    state = state.copyWith(
      medications: state.medications
          .map((m) => m.id == id ? m.copyWith(taken: false) : m)
          .toList(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

const _mockMeds = [
  Medication(id: '1', name: 'Lisinopril',    dose: '10 mg',  schedule: 'Daily',       times: ['8:00 AM']),
  Medication(id: '2', name: 'Metformin',     dose: '500 mg', schedule: 'Twice daily', times: ['8:00 AM', '8:00 PM'], taken: true),
  Medication(id: '3', name: 'Atorvastatin',  dose: '20 mg',  schedule: 'Daily',       times: ['9:00 PM']),
  Medication(id: '4', name: 'Aspirin',       dose: '81 mg',  schedule: 'Daily',       times: ['8:00 AM']),
  Medication(id: '5', name: 'Levothyroxine', dose: '75 mcg', schedule: 'Daily',       times: ['7:00 AM'], taken: true),
  Medication(id: '6', name: 'Omeprazole',    dose: '20 mg',  schedule: 'Daily',       times: ['7:30 AM']),
];

final medicationsProvider =
    NotifierProvider<MedicationsNotifier, MedicationsState>(MedicationsNotifier.new);
