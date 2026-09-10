import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      context.go('/onboarding');
      return;
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (refreshedUser == null) {
      context.go('/login');
    } else if (!refreshedUser.emailVerified) {
      context.go('/verify-email');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: Colors.green),
          ),
          ColoredBox(color: Colors.black.withOpacity(0.48)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'CROC CITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'FOOTBALL ACADEMY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Developing Talent • Building Character • Creating Champions',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 50),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
