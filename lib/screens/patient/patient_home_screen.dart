import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final ApiService api = ApiService();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    futureData = api.getPatientHome(auth.token!);
  }

  Future<void> refresh() async {
    setState(loadData);
  }

  Future<void> logDose(String time) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      await api.logDose(auth.token!, time);
      await refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose logged successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Map<String, dynamic>? getNextMedication(List<dynamic> schedule) {
    for (final med in schedule) {
      final status = (med['tag_class'] ?? '').toString().toLowerCase();
      if (status == 'upcoming') {
        return med as Map<String, dynamic>;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
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
            final patientName = data['patient_name'] ?? auth.fullName ?? 'Patient';
            final adherenceRate = data['adherence_rate'] ?? 0;
            final adherenceNote = data['adherence_note'] ?? '';
            final nextDue = data['next_due'];
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
                          Expanded(
                            child: SectionTitle(
                              title:
                              'Welcome back, ${patientName.toString().split(" ").first}',
                              subtitle: 'Your medication overview for today',
                            ),
                          ),
                          AvatarCircle(
                            initial: patientName.toString()[0],
                            size: 62,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (nextDue != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryHover,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x553B5FE0),
                              blurRadius: 25,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StatusBadge(
                              label: 'NEXT DOSE',
                              status: 'upcoming',
                            ),
                            const SizedBox(height: 18),
                            Text(
                              nextDue['name'] ?? 'No medication',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${nextDue['dose'] ?? ''} scheduled for ${nextDue['time'] ?? '--:--'}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              nextDue['time'] ?? '--:--',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Due time',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primary,
                                  ),
                                  onPressed: () {
                                    final time = nextDue['time'];
                                    if (time != null && time != '--:--') {
                                      logDose(time);
                                    }
                                  },
                                  child: const Text('✓ I took it'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white24,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Snoozed')),
                                    );
                                  },
                                  child: const Text('Snooze'),
                                ),
                              ],
                            ),
                          ],
                        ),
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

                    WellbeingTile(
                      title: 'Wellbeing Check-In',
                      subtitle: 'Log mood, energy and side effects',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.wellbeing);
                      },
                    ),

                    const SizedBox(height: 18),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Today's medications",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.text,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.patientSchedule,
                                  );
                                },
                                child: const Text('View schedule →'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (schedule.isEmpty)
                            const Text(
                              'No medication scheduled today.',
                              style: TextStyle(color: AppTheme.textMuted),
                            )
                          else
                            ...schedule.map<Widget>((med) {
                              return MedicationRow(
                                time: med['time'] ?? '--:--',
                                name: med['name'] ?? 'Medication',
                                dose: med['dose'] ?? '',
                                status: med['status'] ?? 'Upcoming',
                                actionLabel:
                                med['tag_class'] == 'upcoming' ? 'Taken' : null,
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