
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/coach.dart';
import '../providers/coach_provider.dart';
import '../widgets/coach_card.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CoachProvider>().listenToCoaches();
    });
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Coach> _filtered(List<Coach> coaches) {
    if (_query.isEmpty) return coaches;
    return coaches.where((coach) {
      return coach.fullName.toLowerCase().contains(_query) ||
          coach.email.toLowerCase().contains(_query) ||
          coach.specialty.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoachProvider>();
    final coaches = _filtered(provider.coaches);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaches'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.loading ? null : provider.listenToCoaches,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'coaches_fab',
        onPressed: () => context.push('/coaches/add'),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add Coach'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search coaches by name, email or specialty',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: MaterialBanner(
                content: Text(provider.error!),
                leading: const Icon(Icons.error_outline),
                actions: [
                  TextButton(
                    onPressed: provider.listenToCoaches,
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: provider.loading && provider.coaches.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : coaches.isEmpty
                    ? _EmptyCoaches(query: _query)
                    : RefreshIndicator(
                        onRefresh: () async => provider.listenToCoaches(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: coaches.length,
                          itemBuilder: (context, index) {
                            final coach = coaches[index];
                            return CoachCard(
                              coach: coach,
                              onTap: () => context.push('/coaches/details/${coach.id}'),
                              onEdit: () => context.push('/coaches/edit/${coach.id}'),
                              onDelete: () => _delete(coach),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Coach coach) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete coach?'),
        content: Text(
          'This will permanently remove ${coach.fullName} from the academy coach directory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await context.read<CoachProvider>().deleteCoach(coach.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coach deleted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _EmptyCoaches extends StatelessWidget {
  const _EmptyCoaches({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'No coaches yet' : 'No coaches found',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Build your technical team by adding your first coach.'
                  : 'Try a different name, email or specialty.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
