import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'home_screen.dart';
import 'player_home_screen.dart';
import '../../../coaches/presentation/screens/coach_home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../parents/presentation/screens/parent_home_screen.dart';
import '../../../players/presentation/screens/players_screen.dart';
import '../../../teams/presentation/screens/teams_screen.dart';
import '../../../coaches/presentation/screens/coaches_screen.dart';
import '../../../finance/presentation/screens/finance_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const _MissingProfileScreen();
    }

    final isAdmin = user.isAdmin;
    final isCoach = user.isCoach;
    final isParent = user.isParent;

    final pages = isAdmin
        ? const <Widget>[
            HomeScreen(),
            PlayersScreen(),
            TeamsScreen(),
            CoachesScreen(),
            const FinanceDashboardScreen(),
            ProfileScreen(),
          ]
        : isCoach
            ? <Widget>[
                CoachHomeScreen(user: user),
                const ProfileScreen(),
              ]
            : isParent
                ? <Widget>[
                    ParentHomeScreen(user: user),
                    const ProfileScreen(),
                  ]
                : <Widget>[
                    PlayerHomeScreen(user: user),
                    const ProfileScreen(),
                  ];

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: isAdmin
            ? const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Players'),
                NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Teams'),
                NavigationDestination(icon: Icon(Icons.sports_outlined), selectedIcon: Icon(Icons.sports), label: 'Coaches'),
                NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finance'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
              ]
            : const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
              ],
      ),
    );
  }
}

class _MissingProfileScreen extends StatelessWidget {
  const _MissingProfileScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Account profile unavailable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please sign in again or contact the academy administrator.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.loading
                    ? null
                    : () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go('/login');
                      },
                child: Text(auth.loading ? 'Signing out…' : 'Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
