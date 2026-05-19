import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  final ApiService api = ApiService();

  String? mood;
  String? energy;
  String? sideEffects;
  bool loading = false;

  Future<void> saveCheckin() async {
    if (mood == null || energy == null || sideEffects == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    setState(() => loading = true);

    try {
      await api.saveWellbeing(
        token: auth.token!,
        mood: mood!,
        energy: energy!,
        sideEffects: sideEffects!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wellbeing check-in saved')),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wellbeing Check-In',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'How are you feeling today?',
                      subtitle: 'This will be visible to your caregiver and clinician.',
                    ),
                    const SizedBox(height: 24),

                    questionBlock(
                      title: 'Mood',
                      options: ['Very good', 'Good', 'Neutral', 'Low', 'Very low'],
                      selected: mood,
                      onSelected: (value) => setState(() => mood = value),
                    ),

                    questionBlock(
                      title: 'Energy',
                      options: ['High', 'Moderate', 'Low', 'Very low'],
                      selected: energy,
                      onSelected: (value) => setState(() => energy = value),
                    ),

                    questionBlock(
                      title: 'Side effects',
                      options: ['None', 'Nausea', 'Dizziness', 'Headache', 'Fatigue', 'Other'],
                      selected: sideEffects,
                      onSelected: (value) => setState(() => sideEffects = value),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : saveCheckin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Save check-in',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget questionBlock({
    required String title,
    required List<String> options,
    required String? selected,
    required Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final active = selected == option;

              return ChoiceChip(
                label: Text(option),
                selected: active,
                onSelected: (_) => onSelected(option),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.primaryLight,
                labelStyle: TextStyle(
                  color: active ? Colors.white : AppTheme.text,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: active ? AppTheme.primary : AppTheme.border,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}