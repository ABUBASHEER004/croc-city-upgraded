import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';
import 'parent_details_screen.dart';

class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  String query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ParentProvider>().listenToParents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentProvider>();
    final filtered = provider.parents.where((p) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return '${p.fullName} ${p.email} ${p.phone}'
          .toLowerCase()
          .contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parents & Guardians'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.listenToParents();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'Search parents…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.loading && provider.parents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.error != null && filtered.isEmpty)
              _StateCard(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load parents',
                message: provider.error!,
                action: () => provider.listenToParents(),
              )
            else if (filtered.isEmpty)
              const _StateCard(
                icon: Icons.family_restroom_outlined,
                title: 'No parents found',
                message: 'Registered parents will appear here.',
              )
            else
              ...filtered.map(
                (parent) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      backgroundImage:
                          parent.photoUrl?.isNotEmpty == true
                              ? NetworkImage(parent.photoUrl!)
                              : null,
                      child: parent.photoUrl?.isNotEmpty == true
                          ? null
                          : const Icon(Icons.person_outline),
                    ),
                    title: Text(
                      parent.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      parent.email.isEmpty ? parent.phone : parent.email,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParentDetailsScreen(
                          parentId: parent.uid,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: action,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
