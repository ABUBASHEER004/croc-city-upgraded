import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:croc_city_football_academy/features/players/data/models/player.dart';
import 'package:croc_city_football_academy/features/players/presentation/widgets/player_statistics.dart';

void main() {
  testWidgets('Player statistics renders player information', (tester) async {
    final player = Player(
      id: 'player-1',
      registrationNo: 'CCA-001',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phone: '08000000000',
      address: 'Abuja',
      gender: 'Male',
      dateOfBirth: DateTime(2010, 1, 1),
      teamId: 'team-1',
      position: 'Forward',
      jerseyNumber: 9,
      preferredFoot: 'Right',
      parentName: 'Parent Doe',
      parentPhone: '08000000001',
      emergencyContact: '08000000002',
      medicalNotes: '',
      photoUrl: '',
      active: true,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerStatistics(
            player: player,
            teamName: 'U-17',
          ),
        ),
      ),
    );

    expect(find.text('Jersey'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('U-17'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);
  });
}
