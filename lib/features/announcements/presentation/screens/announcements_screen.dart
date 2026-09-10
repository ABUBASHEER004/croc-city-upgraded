import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Announcements')),
      floatingActionButton: auth.isAdmin && user != null
          ? FloatingActionButton.extended(
              onPressed: () => _compose(context, user),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('New announcement'),
            )
          : null,
      body: StreamBuilder<List<Announcement>>(
        stream: AnnouncementService().watchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Unable to load announcements.\n${snapshot.error}', textAlign: TextAlign.center));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.where((a) => a.active).toList();
          if (items.isEmpty) return const Center(child: Text('No announcements have been published yet.'));
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final a = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(child: Icon(a.priority.toLowerCase() == 'urgent' ? Icons.priority_high : Icons.campaign_outlined)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                          if (a.priority.toLowerCase() == 'urgent') const Chip(label: Text('URGENT')),
                        ]),
                        const SizedBox(height: 8),
                        Text(a.message),
                        const SizedBox(height: 10),
                        Text('${DateFormat('d MMM yyyy · h:mm a').format(a.publishedAt)} · ${a.publishedByName}', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static Future<void> _compose(BuildContext context, AppUser user) async {
    final result = await showModalBottomSheet<Announcement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AnnouncementEditor(user: user),
    );
    if (result == null || !context.mounted) return;
    try {
      await AnnouncementService().save(result);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement published to the academy feed.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish announcement: $e')));
    }
  }
}

class _AnnouncementEditor extends StatefulWidget {
  const _AnnouncementEditor({required this.user});
  final AppUser user;
  @override
  State<_AnnouncementEditor> createState() => _AnnouncementEditorState();
}

class _AnnouncementEditorState extends State<_AnnouncementEditor> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _message = TextEditingController();
  String _priority = 'Normal';
  String _audience = 'Everyone';

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, Announcement(
      id: '',
      title: _title.text.trim(),
      message: _message.text.trim(),
      publishedAt: DateTime.now(),
      priority: _priority,
      audience: _audience,
      publishedBy: widget.user.uid,
      publishedByName: widget.user.fullName,
      active: true,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Form(
          key: _formKey,
          child: ListView(shrinkWrap: true, children: [
            Text('Publish academy announcement', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Headline', prefixIcon: Icon(Icons.title)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a headline' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _message, maxLines: 6, decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a message' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _priority, decoration: const InputDecoration(labelText: 'Priority'), items: const ['Normal', 'Important', 'Urgent'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _priority = v ?? 'Normal')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _audience, decoration: const InputDecoration(labelText: 'Audience'), items: const ['Everyone', 'Players', 'Parents', 'Coaches'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _audience = v ?? 'Everyone')),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.send_outlined), label: const Text('Publish now')),
          ]),
        ),
      );
}
