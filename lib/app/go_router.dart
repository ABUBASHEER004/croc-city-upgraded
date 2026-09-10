import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/players/presentation/screens/add_player_screen.dart';
import '../features/players/presentation/screens/edit_player_screen.dart';
import '../features/players/presentation/screens/player_details_screen.dart';
import '../features/players/presentation/screens/players_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/teams/presentation/screens/add_team_screen.dart';
import '../features/teams/presentation/screens/assign_players_screen.dart';
import '../features/teams/presentation/screens/edit_team_screen.dart';
import '../features/teams/presentation/screens/team_details_screen.dart';
import '../features/teams/presentation/screens/teams_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/parents/presentation/screens/parent_home_screen.dart';
import '../features/coaches/presentation/screens/add_coach_screen.dart';
import '../features/coaches/presentation/screens/coach_details_screen.dart';
import '../features/coaches/presentation/screens/coaches_screen.dart';
import '../features/coaches/presentation/screens/edit_coach_screen.dart';
import '../features/coaches/presentation/screens/coach_players_screen.dart';
import '../features/coaches/presentation/screens/player_coach_selection_screen.dart';
import '../features/parents/presentation/screens/parents_screen.dart';
import '../features/fixtures/presentation/screens/fixtures_screen.dart';
import '../features/attendance/presentation/screens/attendance_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/training/presentation/screens/training_screen.dart';
import '../features/announcements/presentation/screens/announcements_screen.dart';
import '../features/finance/presentation/screens/finance_dashboard_screen.dart';
import '../features/finance/presentation/screens/create_invoice_screen.dart';
import '../features/finance/presentation/screens/fee_categories_screen.dart';
import '../features/finance/presentation/screens/payment_history_screen.dart';
import '../features/finance/presentation/screens/scholarship_screen.dart';
import '../presentation/providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/parents',
        builder: (context, state) => const ParentsScreen(),
      ),
      GoRoute(
        path: '/fixtures',
        builder: (context, state) => const FixturesScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/training',
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceDashboardScreen(),
      ),
      GoRoute(
        path: '/finance/invoices/new',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: '/finance/payments',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/finance/categories',
        builder: (context, state) => const FeeCategoriesScreen(),
      ),
      GoRoute(
        path: '/finance/scholarships',
        builder: (context, state) => const ScholarshipScreen(),
      ),
      GoRoute(
        path: '/parent/finance',
        builder: (context, state) => const FinanceDashboardScreen(),
      ),
      GoRoute(
        path: '/players',
        builder: (context, state) => const PlayersScreen(),
      ),
      GoRoute(
        path: '/players/add',
        builder: (context, state) => const AddPlayerScreen(),
      ),
      GoRoute(
        path: '/players/details/:id',
        builder: (context, state) => PlayerDetailsScreen(
          playerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/players/edit/:id',
        builder: (context, state) => EditPlayerScreen(
          playerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/coaches',
        builder: (context, state) => const CoachesScreen(),
      ),
      GoRoute(
        path: '/coaches/add',
        builder: (context, state) => const AddCoachScreen(),
      ),
      GoRoute(
        path: '/coaches/details/:id',
        builder: (context, state) => CoachDetailsScreen(
          coachId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/coach/players',
        builder: (context, state) => CoachPlayersScreen(
          user: context.read<AuthProvider>().currentUser!,
        ),
      ),
      GoRoute(
        path: '/player/coach',
        builder: (context, state) => PlayerCoachSelectionScreen(
          user: context.read<AuthProvider>().currentUser!,
        ),
      ),
      GoRoute(
        path: '/coaches/edit/:id',
        builder: (context, state) => EditCoachScreen(
          coachId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamsScreen(),
      ),
      GoRoute(
        path: '/teams/add',
        builder: (context, state) => const AddTeamScreen(),
      ),
      GoRoute(
        path: '/teams/edit/:id',
        builder: (context, state) => EditTeamScreen(
          teamId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/teams/details/:id',
        builder: (context, state) => TeamDetailsScreen(
          teamId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/teams/assign/:id',
        builder: (context, state) => AssignPlayersScreen(
          teamId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'The page could not be found.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
