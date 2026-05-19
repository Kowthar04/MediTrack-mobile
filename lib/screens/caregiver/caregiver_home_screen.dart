import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final ApiService api = ApiService();
  Future<Map<String, dynamic>>? futureData;

  @override
  void initState() {
    super.initState();
    loadInitialPatient();
  }

  Future<void> loadInitialPatient() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final patientsData = await api.getCaregiverPatients(auth.token!);
    final patients = patientsData['patients'] as List<dynamic>? ?? [];

    if (patients.isNotEmpty && auth.selectedPatientId == null) {
      auth.selectedPatientId = patients.first['patient_id'];
      auth.selectedPatientName = patients.first['full_name'];
    }

    if (auth.selectedPatientId == null) return;

    setState(() {
      futureData = api.getCaregiverPatientHome(
        auth.token!,
        auth.selectedPatientId!,
      );
    });
  }

  Future<void> refresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.selectedPatientId == null) return;

    setState(() {
      futureData = api.getCaregiverPatientHome(
        auth.token!,
        auth.selectedPatientId!,
      );
    });
  }

  Future<void> logDose(String time) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await api.logDose(
      auth.token!,
      time,
      patientId: auth.selectedPatientId,
    );

    await refresh();
  }

  Map<String, dynamic>? getNextMedication(List<dynamic> schedule) {
    for (final med in schedule) {
      final status = (med['tag_class'] ?? '').toString().toLowerCase();
      if (status == 'upcoming') {
        return med as Map<String, dynamic>;
      }
    }

    if (schedule.isNotEmpty) {
      return schedule.last as Map<String, dynamic>;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: futureData == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                          color: AppTheme.danger,
                          size: 34,
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
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: refresh,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final patientName = data['patient_name'] ??
                auth.selectedPatientName ??
                'Patient';
            final adherenceRate = data['adherence_rate'] ?? 0;
            final adherenceNote = data['adherence_note'] ?? '';
            final schedule = data['schedule'] as List<dynamic>? ?? [];
            final nextMed = getNextMedication(schedule);

            return RefreshIndicator(
              onRefresh: refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: MediLogo()),
                        LogoutButton(
                          onTap: () {
                            auth.logout();
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    AppCard(
                      child: Row(
                        children: [
                          AvatarCircle(
                            initial: patientName.toString()[0],
                            size: 62,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SectionTitle(
                              title: 'Monitoring $patientName',
                              subtitle:
                              'Caregiver medication overview',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        ActionButton(
                          icon: Icons.people_alt_rounded,
                          label: 'Change patient',
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.caregiverPicker,
                            );
                            await refresh();
                          },
                        ),
                        const SizedBox(width: 10),
                        ActionButton(
                          icon: Icons.note_alt_rounded,
                          label: 'View / Add Notes',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.caregiverNotes,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatBox(
                            title: 'Today’s adherence',
                            value: '$adherenceRate%',
                            subtitle: adherenceNote,
                            icon: Icons.pie_chart_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBox(
                            title: 'Next scheduled',
                            value: nextMed == null
                                ? '--:--'
                                : nextMed['time'] ?? '--:--',
                            subtitle: nextMed == null
                                ? 'No medication scheduled'
                                : '${nextMed['name'] ?? 'Medication'} · ${nextMed['dose'] ?? ''}',
                            icon: Icons.schedule_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medication Schedule',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.text,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (schedule.isEmpty)
                            const Text(
                              'No medication scheduled today.',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                              ),
                            )
                          else
                            ...schedule.map<Widget>((med) {
                              return MedicationRow(
                                time: med['time'] ?? '--:--',
                                name: med['name'] ?? 'Medication',
                                dose: med['dose'] ?? '',
                                status: med['status'] ?? 'Upcoming',
                                actionLabel:
                                med['tag_class'] == 'upcoming'
                                    ? 'Log'
                                    : null,
                                onAction: med['tag_class'] == 'upcoming'
                                    ? () => logDose(med['time'])
                                    : null,
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}