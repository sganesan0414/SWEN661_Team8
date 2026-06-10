import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';

class RemindersNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() => [];

  void add(Reminder reminder) => state = [...state, reminder];

  void update(Reminder reminder) => state = [
        for (final r in state)
          if (r.id == reminder.id) reminder else r,
      ];

  void delete(String id) =>
      state = state.where((r) => r.id != id).toList();

  void toggle(String id) => state = [
        for (final r in state)
          if (r.id == id) r.copyWith(isEnabled: !r.isEnabled) else r,
      ];
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, List<Reminder>>(RemindersNotifier.new);
