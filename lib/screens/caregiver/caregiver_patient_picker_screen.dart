import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class CaregiverPatientPickerScreen extends StatefulWidget {
  const CaregiverPatientPickerScreen({super.key});

  @override
  State<CaregiverPatientPickerScreen> createState() =>
      _CaregiverPatientPickerScreenState();
}

class _CaregiverPatientPickerScreenState
    extends State<CaregiverPatientPickerScreen> {
  final ApiService api = ApiService();

  late Future<Map<String, dynamic>> futurePatients;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);

    futurePatients = api.getCaregiverPatients(auth.token!);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text(
          'Select Patient',
          style: TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppTheme.text,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futurePatients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: AppTheme.danger,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.dangerText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final patients = data['patients'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned patients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose who you are currently monitoring',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              ...patients.map<Widget>((patient) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: AvatarCircle(
                        initial: patient['full_name'][0],
                        size: 44,
                      ),

                      title: Text(
                        patient['full_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text,
                        ),
                      ),

                      subtitle: Text(
                        'Patient ID: ${patient['patient_id']}',
                      ),

                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                      ),

                      onTap: () {
                        auth.selectedPatientId =
                        patient['patient_id'];

                        auth.selectedPatientName =
                        patient['full_name'];

                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}