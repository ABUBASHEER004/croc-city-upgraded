import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../teams/presentation/providers/team_provider.dart';
import '../../data/models/player.dart';
import '../../data/player_result_pdf_service.dart';
import '../../data/player_result_service.dart';
import '../../data/services/player_firestore_service.dart';

class PlayerResultScreen extends StatefulWidget {
  const PlayerResultScreen({super.key, required this.playerId});
  final String playerId;

  @override
  State<PlayerResultScreen> createState() => _PlayerResultScreenState();
}

class _PlayerResultScreenState extends State<PlayerResultScreen> {
  final _service = PlayerResultService();
  final _pdfService = PlayerResultPdfService();
  final _termController = TextEditingController(text: 'First Term');
  final _sessionController = TextEditingController(text: '2026/2027');
  final _commentController = TextEditingController();
  final List<_AssessmentRow> _rows = [
    _AssessmentRow('Technical Ability'),
    _AssessmentRow('Tactical Understanding'),
    _AssessmentRow('Physical Development'),
    _AssessmentRow('Discipline & Attitude'),
    _AssessmentRow('Attendance & Commitment'),
  ];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<TeamProvider>();
      if (provider.teams.isEmpty && !provider.loading) provider.listenToTeams();
    });
  }

  @override
  void dispose() {
    _termController.dispose();
    _sessionController.dispose();
    _commentController.dispose();
    for (final row in _rows) row.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Player?>(
      future: PlayerFirestoreService.instance.getPlayer(widget.playerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(appBar: AppBar(title: const Text('Player Results')), body: Center(child: Text(snapshot.hasError ? 'Unable to load player.\n${snapshot.error}' : 'Player not found.')));
        }
        return _buildScreen(context, snapshot.data!);
      },
    );
  }

  Widget _buildScreen(BuildContext context, Player player) {
    final teams = context.watch<TeamProvider>();
    final team = teams.getTeamById(player.teamId);
    final teamName = team?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Results · ${player.fullName}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(player.fullName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${player.registrationNo.isEmpty ? player.id : player.registrationNo} · ${player.position.isEmpty ? 'Player' : player.position}'),
            if (teamName.isNotEmpty) Text('Team: $teamName'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: TextField(controller: _termController, decoration: const InputDecoration(labelText: 'Term', prefixIcon: Icon(Icons.calendar_month_outlined)))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _sessionController, decoration: const InputDecoration(labelText: 'Session', prefixIcon: Icon(Icons.school_outlined)))),
            ],),
          ]))),
          const SizedBox(height: 14),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Performance assessments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Score each area from 0 to 100. The parent will only see this report after you publish it.'),
            const SizedBox(height: 12),
            ..._rows.asMap().entries.map((entry) => _assessmentField(entry.value)),
            const SizedBox(height: 4),
            TextField(controller: _commentController, maxLines: 4, decoration: const InputDecoration(labelText: "Coach's comment", alignLabelWithHint: true, prefixIcon: Icon(Icons.rate_review_outlined))),
          ]))),
          const SizedBox(height: 14),
          SizedBox(height: 52, child: FilledButton.icon(
            onPressed: _saving ? null : () => _publish(player, teamName),
            icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.publish_rounded),
            label: Text(_saving ? 'Publishing…' : 'Publish result to parent'),
          )),
          const SizedBox(height: 24),
          const Text('Previously published', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _publishedResults(player),
        ],
      ),
    );
  }

  Widget _assessmentField(_AssessmentRow row) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w700))),
      const SizedBox(width: 10),
      SizedBox(width: 100, child: TextField(controller: row.score, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Score'))),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: row.remark, decoration: const InputDecoration(labelText: 'Remark'))),
    ]),
  );

  Widget _publishedResults(Player player) => StreamBuilder<List<Map<String, dynamic>>>(
    stream: _service.watchResults(player.id),
    builder: (context, snapshot) {
      if (snapshot.hasError) return Text('Unable to load published results: ${snapshot.error}');
      if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
      final items = snapshot.data ?? const <Map<String, dynamic>>[];
      if (items.isEmpty) return const Text('No results published yet.');
      return Column(children: items.map((item) => Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.picture_as_pdf_rounded)),
        title: Text('${item['term'] ?? ''} · ${item['session'] ?? ''}'),
        subtitle: Text(_dateLabel(item['publishedAt'] ?? item['createdAt'])),
        trailing: const Icon(Icons.cloud_done_rounded),
      ))).toList());
    },
  );

  Future<void> _publish(Player player, String teamName) async {
    final term = _termController.text.trim();
    final session = _sessionController.text.trim();
    if (term.isEmpty || session.isEmpty) return _snack('Term and session are required.');
    if (player.parentId.trim().isEmpty) return _snack('Link a parent to this player before publishing a result.');

    final assessments = <Map<String, dynamic>>[];
    for (final row in _rows) {
      final raw = row.score.text.trim();
      final score = double.tryParse(raw);
      if (score == null || score < 0 || score > 100) return _snack('Enter a score from 0 to 100 for ${row.name}.');
      assessments.add({'assessment': row.name, 'score': score, 'grade': _grade(score), 'remark': row.remark.text.trim()});
    }

    setState(() => _saving = true);
    try {
      final resultId = await _service.saveResult(
        playerId: player.id,
        parentId: player.parentId,
        playerName: player.fullName,
        term: term,
        session: session,
        assessments: assessments,
        coachComment: _commentController.text.trim(),
      );
      final bytes = await _pdfService.buildPdf(
        playerName: player.fullName,
        playerId: player.id,
        registrationNo: player.registrationNo,
        teamName: teamName,
        position: player.position,
        term: term,
        session: session,
        assessments: assessments,
        coachComment: _commentController.text.trim(),
        photoUrl: player.photoUrl,
      );
      final pdfUrl = await _pdfService.publishPdf(resultId: resultId, playerId: player.id, bytes: bytes);
      await _service.publishResult(resultId: resultId, pdfUrl: pdfUrl);
      if (mounted) _snack('Result published. The parent can see it in real time now.');
    } catch (error) {
      if (mounted) _snack(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  String _grade(double score) {
    if (score >= 70) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }

  String _dateLabel(dynamic value) {
    if (value is Timestamp) return '${value.toDate().day}/${value.toDate().month}/${value.toDate().year}';
    return '';
  }
}

class _AssessmentRow {
  _AssessmentRow(this.name);
  final String name;
  final TextEditingController score = TextEditingController();
  final TextEditingController remark = TextEditingController();
  void dispose() { score.dispose(); remark.dispose(); }
}
