
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/auth_button.dart';
import '../../../dashboard/presentation/widgets/auth_header.dart';
import '../../../dashboard/presentation/widgets/auth_text_field.dart';
import '../../../dashboard/presentation/widgets/password_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _restoreEmail();
  }

  Future<void> _restoreEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth.rememberedEmail');

    if (!mounted || saved == null || saved.isEmpty) {
      return;
    }

    setState(() {
      emailController.text = saved;
      rememberMe = true;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final email = emailController.text.trim();

      final prefs = await SharedPreferences.getInstance();

      if (rememberMe) {
        await prefs.setString(
          'auth.rememberedEmail',
          email,
        );
      } else {
        await prefs.remove('auth.rememberedEmail');
      }

      final auth = context.read<AuthProvider>();

      await auth.login(
        email: email,
        password: passwordController.text,
      );

      if (!mounted) return;

      final firebaseUser = auth.currentUser;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to load your account profile.',
        );
      }

      if (!firebaseUser.emailVerified) {
        context.go('/verify-email');
        return;
      }

      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;

      _showError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        const AuthHeader(
                          title: 'Welcome Back',
                          subtitle:
                              'Sign in to continue to Croc City Football Academy',
                        ),

                        const SizedBox(height: 40),

                        AuthTextField(
                          controller: emailController,
                          label: 'Username or Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Email is required';
                            }

                            if (email.contains('@') && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
                              return 'Enter a valid email address or username';
                            }
                            if (!email.contains('@') && !RegExp(r'^[a-zA-Z0-9._-]{3,}$').hasMatch(email)) {
                              return 'Enter a valid username';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        PasswordTextField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Password is required';
                            }

                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: loading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        rememberMe =
                                            value ?? false;
                                      });
                                    },
                            ),
                            const Text('Remember Me'),
                            const Spacer(),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => context.push(
                                        '/forgot-password',
                                      ),
                              child:
                                  const Text('Forgot Password?'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        AuthButton(
                          text: 'LOGIN',
                          loading: loading,
                          onPressed: login,
                        ),

                        const SizedBox(height: 22),



                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (loading)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

