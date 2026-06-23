// Forces every lib/ file into the coverage denominator so the
// reported percentage reflects the whole codebase, not just touched files.
// ignore_for_file: unused_import
import 'package:careconnect/main.dart';
import 'package:careconnect/components/widgets.dart';
import 'package:careconnect/models/appointment.dart';
import 'package:careconnect/models/care_team_member.dart';
import 'package:careconnect/models/health_metric.dart';
import 'package:careconnect/models/health_report.dart';
import 'package:careconnect/models/medication.dart';
import 'package:careconnect/models/reminder.dart';
import 'package:careconnect/providers/account_provider.dart';
import 'package:careconnect/providers/appointments_provider.dart';
import 'package:careconnect/providers/care_team_provider.dart';
import 'package:careconnect/providers/health_metrics_provider.dart';
import 'package:careconnect/providers/health_reports_provider.dart';
import 'package:careconnect/providers/medications_provider.dart';
import 'package:careconnect/providers/reminders_provider.dart';
import 'package:careconnect/screens/add_edit_reminder_screen.dart';
import 'package:careconnect/screens/appointments_screen.dart';
import 'package:careconnect/screens/care_team_screen.dart';
import 'package:careconnect/screens/create_account.dart';
import 'package:careconnect/screens/dashboard_screen.dart';
import 'package:careconnect/screens/health_metrics_screen.dart';
import 'package:careconnect/screens/health_reports_screen.dart';
import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/screens/medications_screen.dart';
import 'package:careconnect/screens/pharmacy.dart';
import 'package:careconnect/screens/pin_screen.dart';
import 'package:careconnect/screens/reminders.dart';
import 'package:careconnect/screens/user_profile.dart';
import 'package:careconnect/screens/user_settings.dart';
import 'package:careconnect/services/notification_service.dart';
import 'package:careconnect/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all libraries are included in coverage', () {
    expect(true, isTrue);
  });
}
