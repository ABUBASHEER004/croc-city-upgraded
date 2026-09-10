import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../coaches/presentation/providers/coach_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../data/models/training_session.dart';
import '../../data/training_service.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _service = TrainingService();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loaded) return;
      _loaded = true;
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        context.read<CoachProvider>().listenToCoaches();
        context.read<TeamProvider>().listenToTeams();
      }
    });
  }

  Future<void> _addSession(AppUser user) async {
    final result = await showModalBottomSheet<TrainingSession>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TrainingEditor(user: user),
    );
    if (result == null || !mounted) return;
    try {
      await _service.save(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training schedule published live.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish training: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final canEdit = auth.isAdmin || auth.isCoach;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Centre'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Schedule training',
              onPressed: user == null ? null : () => _addSession(user),
              icon: const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      floatingActionButton: canEdit && user != null
          ? FloatingActionButton.extended(
              onPressed: () => _addSession(user),
              icon: const Icon(Icons.add),
              label: const Text('Schedule session'),
            )
          : null,
      body: StreamBuilder<List<TrainingSession>>(
        stream: _service.watchSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorState(message: snapshot.error.toString());
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sessions = snapshot.data!;
          if (sessions.isEmpty) return const _EmptyTraining();
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final mine = auth.isCoach && session.coachId == user?.uid;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 26,
                      child: Icon(session.scheduledAt.isAfter(DateTime.now()) ? Icons.sports_soccer : Icons.history),
                    ),
                    title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        '${DateFormat('EEE, d MMM · h:mm a').format(session.scheduledAt)}\n'
                        '${session.teamName.isEmpty ? 'Academy squad' : session.teamName} · ${session.location.isEmpty ? 'Location TBA' : session.location}\n'
                        '${session.coachName.isEmpty ? 'Academy coaching team' : session.coachName}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: canEdit && (auth.isAdmin || mine)
                        ? IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _delete(session),
                            icon: const Icon(Icons.delete_outline),
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(TrainingSession session) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Remove training session?'),
        content: Text('Remove ${session.title} from the academy calendar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Remove')),
        ],
      ),
    );
    if (yes != true) return;
    await _service.delete(session.id);
  }
}

class _TrainingEditor extends StatefulWidget {
  const _TrainingEditor({required this.user});
  final AppUser user;

  @override
  State<_TrainingEditor> createState() => _TrainingEditorState();
}

class _TrainingEditorState extends State<_TrainingEditor> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Technical Training');
  final _description = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  int _duration = 90;
  String? _coachId;
  String? _teamId;

  @override
  void initState() {
    super.initState();
    if (widget.user.isCoach) _coachId = widget.user.uid;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (time == null || !mounted) return;
    setState(() => _date = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final coaches = context.read<CoachProvider>().coaches;
    final teams = context.read<TeamProvider>().teams;
    final matchingCoaches = coaches.where((c) => c.id == _coachId).toList();
    final matchingTeams = teams.where((t) => t.id == _teamId).toList();
    final coach = matchingCoaches.isEmpty ? null : matchingCoaches.first;
    final team = matchingTeams.isEmpty ? null : matchingTeams.first;
    if (widget.user.isCoach && _coachId == null) return;

    Navigator.pop(
      context,
      TrainingSession(
        id: '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        scheduledAt: _date,
        durationMinutes: _duration,
        location: _location.text.trim(),
        coachId: _coachId ?? '',
        coachName: coach?.fullName ?? (widget.user.isCoach ? widget.user.fullName : ''),
        teamId: _teamId ?? '',
        teamName: team?.name ?? 'Academy session',
        status: 'Scheduled',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coaches = context.watch<CoachProvider>().coaches;
    final teams = context.watch<TeamProvider>().teams;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Plan a training session', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Session title', prefixIcon: Icon(Icons.title)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Coach notes / focus', prefixIcon: Icon(Icons.notes_outlined))),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Training ground', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.schedule_outlined)),
              title: const Text('Date & time'),
              subtitle: Text(DateFormat('EEE, d MMM yyyy · h:mm a').format(_date)),
              trailing: TextButton(onPressed: _pickDateTime, child: const Text('CHANGE')),
            ),
            DropdownButtonFormField<int>(
              initialValue: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: const [60, 90, 120, 150].map((m) => DropdownMenuItem(value: m, child: Text('$m minutes'))).toList(),
              onChanged: (v) => setState(() => _duration = v ?? 90),
            ),
            if (widget.user.isAdmin) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _coachId,
                decoration: const InputDecoration(labelText: 'Coach', prefixIcon: Icon(Icons.person_outline)),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Academy coaching team')),
                  ...coaches.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName))),
                ],
                onChanged: (v) => setState(() => _coachId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _teamId,
                decoration: const InputDecoration(labelText: 'Team / squad', prefixIcon: Icon(Icons.groups_outlined)),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Academy-wide')),
                  ...teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                ],
                onChanged: (v) => setState(() => _teamId = v),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.publish_outlined), label: const Text('Publish schedule')),
          ],
        ),
      ),
    );
  }
}

class _EmptyTraining extends StatelessWidget {
  const _EmptyTraining();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.event_note_outlined, size: 64), SizedBox(height: 16), Text('No training scheduled', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Published sessions will appear here in real time.', textAlign: TextAlign.center)])));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Unable to load training.\n$message', textAlign: TextAlign.center)));
}
