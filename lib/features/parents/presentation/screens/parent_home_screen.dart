import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/app_user.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Portal'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.photoUrl?.isNotEmpty == true
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.family_restroom_outlined),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.firstName.isEmpty ? 'Parent' : user.firstName}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Stay connected with your child’s academy journey.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PortalCard(
            icon: Icons.groups_outlined,
            title: 'Your children',
            subtitle: 'Player registrations and team information',
            onTap: () => context.push('/players'),
          ),
          _PortalCard(
            icon: Icons.calendar_month_outlined,
            title: 'Fixtures',
            subtitle: 'Upcoming academy matches and events',
            onTap: () => context.push('/fixtures'),
          ),
          _PortalCard(
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            subtitle: 'Important academy communications',
            onTap: () => context.push('/announcements'),
          ),
          _PortalCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Fees & payments',
            subtitle: 'Keep track of academy financial information',
            onTap: () => context.push('/finance'),
          ),
        ],
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            child: Icon(icon),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
