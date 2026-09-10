import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../coaches/presentation/providers/coach_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../models/fixture.dart';
import '../../providers/fixture_provider.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({super.key});

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FixtureProvider>().loadFixtures();
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        context.read<CoachProvider>().listenToCoaches();
        context.read<TeamProvider>().listenToTeams();
      }
    });
  }

  Future<void> _addFixture(AppUser user) async {
    final fixture = await showModalBottomSheet<Fixture>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FixtureEditor(user: user),
    );
    if (fixture == null || !mounted) return;
    try {
      await context.read<FixtureProvider>().saveFixture(fixture);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fixture published live.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save fixture: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<FixtureProvider>();
    final user = auth.currentUser;
    final canEdit = auth.isAdmin || auth.isCoach;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixtures & Matchday'),
        actions: [
          IconButton(onPressed: provider.loading ? null : provider.loadFixtures, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: canEdit && user != null
          ? FloatingActionButton.extended(onPressed: () => _addFixture(user), icon: const Icon(Icons.add), label: const Text('Add fixture'))
          : null,
      body: provider.loading && provider.fixtures.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.fixtures.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No fixtures yet. Publish a match to make matchday information available instantly.', textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: provider.loadFixtures,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    itemCount: provider.fixtures.length,
                    itemBuilder: (context, index) {
                      final f = provider.fixtures[index];
                      final mine = auth.isCoach && f.coachId == user?.uid;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(f.competition.isEmpty ? 'Academy Match' : f.competition, style: const TextStyle(fontWeight: FontWeight.w800))),
                                Chip(label: Text(f.status)),
                              ]),
                              const SizedBox(height: 16),
                              Row(children: [
                                Expanded(child: Text(f.homeTeam, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(f.isFinished || f.isLive ? '${f.homeScore ?? 0} : ${f.awayScore ?? 0}' : 'VS', style: const TextStyle(fontWeight: FontWeight.w900))),
                                Expanded(child: Text(f.awayTeam, textAlign: TextAlign.end, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                              ]),
                              const SizedBox(height: 16),
                              Wrap(spacing: 16, runSpacing: 8, children: [
                                _Meta(icon: Icons.schedule_outlined, text: DateFormat('EEE, d MMM · h:mm a').format(f.date)),
                                _Meta(icon: Icons.location_on_outlined, text: f.venue.isEmpty ? 'Venue TBA' : f.venue),
                              ]),
                              if (f.notes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(f.notes, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                              if (canEdit && (auth.isAdmin || mine))
                                Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => _delete(f), icon: const Icon(Icons.delete_outline))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _delete(Fixture fixture) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Remove fixture?'),
        content: Text('Remove ${fixture.homeTeam} vs ${fixture.awayTeam}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Remove')),
        ],
      ),
    );
    if (yes == true) await context.read<FixtureProvider>().deleteFixture(fixture.id);
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(text)]);
}

class _FixtureEditor extends StatefulWidget {
  const _FixtureEditor({required this.user});
  final AppUser user;
  @override
  State<_FixtureEditor> createState() => _FixtureEditorState();
}

class _FixtureEditorState extends State<_FixtureEditor> {
  final _formKey = GlobalKey<FormState>();
  final _home = TextEditingController(text: 'Croc City FA');
  final _away = TextEditingController();
  final _competition = TextEditingController(text: 'Friendly Match');
  final _venue = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  String _status = 'Scheduled';
  String? _coachId;
  String? _teamId;

  @override
  void initState() {
    super.initState();
    if (widget.user.isCoach) _coachId = widget.user.uid;
  }

  @override
  void dispose() {
    for (final c in [_home, _away, _competition, _venue, _notes]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 1095)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (time == null || !mounted) return;
    setState(() => _date = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, Fixture(
      id: '',
      homeTeam: _home.text.trim(),
      awayTeam: _away.text.trim(),
      date: _date,
      competition: _competition.text.trim(),
      venue: _venue.text.trim(),
      status: _status,
      teamId: _teamId ?? '',
      coachId: _coachId ?? '',
      notes: _notes.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final coaches = context.watch<CoachProvider>().coaches;
    final teams = context.watch<TeamProvider>().teams;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: ListView(shrinkWrap: true, children: [
          Text('Create a fixture', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          TextFormField(controller: _home, decoration: const InputDecoration(labelText: 'Home team', prefixIcon: Icon(Icons.home_outlined)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter home team' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _away, decoration: const InputDecoration(labelText: 'Away team', prefixIcon: Icon(Icons.groups_outlined)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter away team' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _competition, decoration: const InputDecoration(labelText: 'Competition')), 
          const SizedBox(height: 12),
          TextFormField(controller: _venue, decoration: const InputDecoration(labelText: 'Venue', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.schedule)), title: const Text('Match date & time'), subtitle: Text(DateFormat('EEE, d MMM yyyy · h:mm a').format(_date)), trailing: TextButton(onPressed: _pickDateTime, child: const Text('CHANGE'))),
          DropdownButtonFormField<String>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'), items: const ['Scheduled', 'Live', 'Finished', 'Postponed', 'Cancelled'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _status = v ?? 'Scheduled')),
          if (widget.user.isAdmin) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _coachId, decoration: const InputDecoration(labelText: 'Responsible coach'), items: [const DropdownMenuItem(value: '', child: Text('Academy')),...coaches.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)))], onChanged: (v) => setState(() => _coachId = v)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _teamId, decoration: const InputDecoration(labelText: 'Academy team'), items: [const DropdownMenuItem(value: '', child: Text('Academy-wide')),...teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))], onChanged: (v) => setState(() => _teamId = v)),
          ],
          const SizedBox(height: 12),
          TextFormField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Matchday notes')),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.publish_outlined), label: const Text('Publish fixture')),
        ]),
      ),
    );
  }
}
