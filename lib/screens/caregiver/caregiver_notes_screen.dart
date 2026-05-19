import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class CaregiverNotesScreen extends StatefulWidget {
  const CaregiverNotesScreen({super.key});

  @override
  State<CaregiverNotesScreen> createState() => _CaregiverNotesScreenState();
}

class _CaregiverNotesScreenState extends State<CaregiverNotesScreen> {
  final ApiService api = ApiService();
  final noteController = TextEditingController();

  String? selectedTag;
  Future<Map<String, dynamic>>? futureData;

  final List<String> tags = [
    'Mood',
    'Pain',
    'Side effect',
    'Appetite',
    'Sleep',
  ];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    futureData = api.getCaregiverPatientHome(
      auth.token!,
      auth.selectedPatientId!,
    );
  }

  Future<void> refresh() async {
    setState(loadNotes);
  }

  Future<void> saveNote() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final text = noteController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a note first')),
      );
      return;
    }

    try {
      await api.addCaregiverNote(
        auth.token!,
        auth.selectedPatientId!,
        text,
        selectedTag,
      );

      noteController.clear();
      selectedTag = null;

      await refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('${auth.selectedPatientName ?? "Patient"} notes'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          final notes = snapshot.data?['notes'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Add caregiver note',
                        subtitle: 'Record observations for the care team',
                      ),
                      const SizedBox(height: 18),

                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write a note...',
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          final isSelected = selectedTag == tag;

                          return ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryLight,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w800,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedTag = isSelected ? null : tag;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveNote,
                          child: const Text('Save note'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.text,
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (notes.isEmpty)
                        const Text(
                          'No notes yet.',
                          style: TextStyle(color: AppTheme.textMuted),
                        )
                      else
                        ...notes.map<Widget>((note) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.borderSubtle,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (note['tag'] != null)
                                  StatusBadge(
                                    label: note['tag'],
                                    status: 'upcoming',
                                  ),

                                const SizedBox(height: 8),

                                Text(
                                  note['text'] ?? '',
                                  style: const TextStyle(
                                    color: AppTheme.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '${note['author_name'] ?? ''} · ${note['created_at'] ?? ''}',
                                  style: const TextStyle(
                                    color: AppTheme.textSubtle,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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