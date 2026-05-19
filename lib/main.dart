import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/patient_schedule_screen.dart';
import 'screens/caregiver/caregiver_home_screen.dart';
import 'screens/caregiver/caregiver_patient_picker_screen.dart';
import 'screens/caregiver/caregiver_notes_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/patient/wellbeing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MediTrack',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.patientHome: (_) => const PatientHomeScreen(),
          AppRoutes.patientSchedule: (_) => const PatientScheduleScreen(),
          AppRoutes.caregiverHome: (_) => const CaregiverHomeScreen(),
          AppRoutes.caregiverPicker: (_) => const CaregiverPatientPickerScreen(),
          AppRoutes.caregiverNotes: (_) => const CaregiverNotesScreen(),
          AppRoutes.wellbeing: (_) => const WellbeingScreen(),
        },
      ),
    );
  }
}