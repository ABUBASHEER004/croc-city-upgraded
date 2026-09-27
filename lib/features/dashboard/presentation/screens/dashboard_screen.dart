import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'home_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../students/presentation/screens/student_portal_screen.dart';
import '../../../students/presentation/screens/teacher_home_screen.dart';
import 'staff_home_screen.dart';
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
    final isPlayerParent = user.isPlayerParent;
    final isStudent = user.isStudent;
    final isTeacher = user.isTeacher;
    final isStaff = user.isStaff;
    final isStudentParent = user.isStudentParent;

    final pages = isAdmin
        ? const <Widget>[AdminDashboardScreen(), ProfileScreen()]
        : isStudentParent
            ? <Widget>[ParentHomeScreen(user: user), const ProfileScreen()]
            : isTeacher
                ? <Widget>[TeacherHomeScreen(user: user), const ProfileScreen()]
                : isStaff
                    ? <Widget>[StaffHomeScreen(user: user), const ProfileScreen()]
                    : isStudent
                ? <Widget>[StudentPortalScreen(userName: user.fullName, uid: user.uid, parent: false), const ProfileScreen()]
                : isCoach
                    ? <Widget>[CoachHomeScreen(user: user), const ProfileScreen()]
                    : isPlayerParent
                        ? <Widget>[ParentHomeScreen(user: user), const ProfileScreen()]
                        : <Widget>[PlayerHomeScreen(user: user), const ProfileScreen()];

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
                NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Command'),
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
