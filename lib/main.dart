import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'app/app.dart';

// ============================================================
// AUTH PROVIDER
// ============================================================

import 'presentation/providers/auth_provider.dart';

// ============================================================
// TEAM
// ============================================================

import 'features/teams/presentation/providers/team_provider.dart';
import 'features/teams/data/repository/team_repository.dart';
import 'features/teams/data/services/team_firestore_service.dart';

// ============================================================
// PLAYER
// ============================================================

import 'features/players/presentation/providers/player_provider.dart';
import 'features/players/data/repository/player_repository.dart';
import 'features/players/data/services/player_firestore_service.dart';

// COACHES
import 'features/coaches/presentation/providers/coach_provider.dart';
import 'features/coaches/data/repository/coach_repository.dart';
import 'features/coaches/data/services/coach_firestore_service.dart';
import 'features/parents/presentation/providers/parent_provider.dart';
import 'features/parents/data/parent_repository.dart';
import 'features/matches/providers/fixture_provider.dart';

Future<void> main() async {
  // Make sure Flutter is initialized before Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // FIREBASE INITIALIZATION
  // ==========================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================================
  // TEAM REPOSITORY
  // ==========================================================

  final teamRepository = TeamRepository(
    TeamFirestoreService.instance,
  );

  // ==========================================================
  // PLAYER REPOSITORY
  // ==========================================================

  final playerRepository = PlayerRepository(
    PlayerFirestoreService.instance,
  );

  final coachRepository = CoachRepository(
    CoachFirestoreService.instance,
  );

  final parentRepository = ParentRepository();

  // ==========================================================
  // RUN APP
  // ==========================================================

  runApp(
    MultiProvider(
      providers: [
        // ------------------------------------------------------
        // AUTH
        // ------------------------------------------------------

        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        // ------------------------------------------------------
        // TEAM
        // ------------------------------------------------------

        ChangeNotifierProvider<TeamProvider>(
          create: (_) => TeamProvider(
            teamRepository,
          ),
        ),

        // ------------------------------------------------------
        // PLAYER
        // ------------------------------------------------------

        ChangeNotifierProvider<PlayerProvider>(
          create: (_) => PlayerProvider(
            playerRepository,
          ),
        ),

        ChangeNotifierProvider<CoachProvider>(
          create: (_) => CoachProvider(
            coachRepository,
          ),
        ),

        ChangeNotifierProvider<ParentProvider>(
          create: (_) => ParentProvider(
            parentRepository,
          ),
        ),

        ChangeNotifierProvider<FixtureProvider>(
          create: (_) => FixtureProvider(),
        ),
      ],

      child: const CrocCityFootballAcademy(),
    ),
  );
}