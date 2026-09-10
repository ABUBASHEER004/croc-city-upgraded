import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../players/presentation/providers/player_provider.dart';
import '../../data/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _service = AttendanceService();
  DateTime selectedDate = DateTime.now();
  final Map<String, String> statuses = {};
  bool saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final players = context.read<PlayerProvider>();
      if (auth.isCoach) {
        players.listenToCoach(auth.currentUser!.uid);
      } else if (players.players.isEmpty) {
        players.startListening();
      }
    });
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => selectedDate = picked);
  }

  Future<void> _saveAll(AppUser user) async {
    if (saving) return;
    final players = context.read<PlayerProvider>().players;
    if (players.isEmpty) return;
    setState(() => saving = true);
    try {
      await _service.setBulkAttendance(
        players: players
            .map((p) => {'id': p.id, 'name': p.fullName})
            .toList(),
        date: selectedDate,
        coachId: user.isCoach ? user.uid : 'admin',
        statuses: statuses,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance published. Players can see the update immediately.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save attendance: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PlayerProvider>();
    final user = auth.currentUser;
    final players = provider.players;
    final canEdit = auth.isAdmin || auth.isCoach;

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isCoach ? 'My Players · Attendance' : 'Attendance Centre'),
        actions: [
          IconButton(onPressed: _chooseDate, icon: const Icon(Icons.calendar_month_outlined)),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: saving || players.isEmpty || user == null ? null : () => _saveAll(user),
              icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.publish_outlined),
              label: Text(saving ? 'Publishing…' : 'Publish attendance'),
            )
          : null,
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.event_available_outlined)),
              title: const Text('Session date', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'),
              trailing: TextButton(onPressed: _chooseDate, child: const Text('CHANGE')),
            ),
          ),
          Expanded(
            child: provider.loading && players.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : players.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(auth.isCoach ? 'No players are assigned to you yet.' : 'No players are available.', textAlign: TextAlign.center)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        itemCount: players.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final status = statuses[player.id] ?? 'Present';
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: player.photoUrl.isNotEmpty ? NetworkImage(player.photoUrl) : null,
                                child: player.photoUrl.isNotEmpty ? null : Text(player.firstName.isEmpty ? '?' : player.firstName[0].toUpperCase()),
                              ),
                              title: Text(player.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('#${player.jerseyNumber} · ${player.position}'),
                              trailing: canEdit
                                  ? DropdownButton<String>(
                                      value: status,
                                      underline: const SizedBox.shrink(),
                                      items: const [
                                        DropdownMenuItem(value: 'Present', child: Text('Present')),
                                        DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                                        DropdownMenuItem(value: 'Late', child: Text('Late')),
                                        DropdownMenuItem(value: 'Excused', child: Text('Excused')),
                                      ],
                                      onChanged: (value) => setState(() => statuses[player.id] = value ?? 'Present'),
                                    )
                                  : Chip(label: Text(status)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
