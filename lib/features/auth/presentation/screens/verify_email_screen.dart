import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  bool canResend = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    sendVerificationEmail();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      await user.sendEmailVerification();

      if (!mounted) return;

      setState(() {
        canResend = false;
      });

      await Future.delayed(
        const Duration(seconds: 30),
      );

      if (!mounted) return;

      setState(() {
        canResend = true;
      });
    } catch (_) {}
  }

  Future<void> checkEmailVerified() async {
    await _auth.currentUser?.reload();

    final user = _auth.currentUser;

    if (user == null) return;

    if (user.emailVerified) {
      timer?.cancel();

      if (!mounted) return;

      await context.read<AuthProvider>().refreshCurrentUser();

      if (!mounted) return;
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: Colors.green,
              ),

              const SizedBox(height: 30),

              const Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "A verification link has been sent to\n$email",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              ElevatedButton.icon(
                onPressed: loading
                    ? null
                    : checkEmailVerified,
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "I've Verified My Email",
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: canResend
                    ? sendVerificationEmail
                    : null,
                child: const Text(
                  "Resend Verification Email",
                ),
              ),

              const SizedBox(height: 40),

              OutlinedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().logout();
                  } finally {
                    if (mounted) context.go('/login');
                  }
                },
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}