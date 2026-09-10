import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/auth_button.dart';
import '../../../dashboard/presentation/widgets/auth_header.dart';
import '../../../dashboard/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = context.read<AuthProvider>();

      await auth.resetPassword(
        emailController.text.trim(),
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Email Sent"),
          content: const Text(
            "A password reset link has been sent to your email address.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (!mounted) return;

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const AuthHeader(
                      title: "Reset Password",
                      subtitle:
                          "Enter your email to receive a password reset link.",
                    ),

                    const SizedBox(height: 40),

                    AuthTextField(
                      controller: emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return "Email is required";
                        }

                        final emailRegex = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+$',
                        );

                        if (!emailRegex.hasMatch(
                          value.trim(),
                        )) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    AuthButton(
                      text: "SEND RESET LINK",
                      loading: loading,
                      onPressed: resetPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}