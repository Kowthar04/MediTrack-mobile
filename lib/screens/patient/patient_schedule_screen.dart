import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class PatientScheduleScreen extends StatefulWidget {
  const PatientScheduleScreen({super.key});

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  final ApiService api = ApiService();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    futureData = api.getPatientSchedule(auth.token!);
  }

  Future<void> refresh() async {
    setState(loadData);
  }

  Future<void> logDose(String time) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await api.logDose(auth.token!, time);
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Medication Schedule')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final schedule = snapshot.data?['schedule'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const AppCard(
                  child: SectionTitle(
                    title: "Today's Medications",
                    subtitle: 'Track your doses and timings',
                  ),
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Column(
                    children: [
                      if (schedule.isEmpty)
                        const Text('No medications scheduled.')
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
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}