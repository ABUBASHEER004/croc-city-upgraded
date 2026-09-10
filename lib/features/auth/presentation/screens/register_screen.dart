import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/user_role.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/auth_button.dart';
import '../../../dashboard/presentation/widgets/auth_header.dart';
import '../../../dashboard/presentation/widgets/auth_text_field.dart';
import '../../../dashboard/presentation/widgets/password_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  UserRole selectedRole = UserRole.player;

  final List<UserRole> roles = const [
    UserRole.player,
    UserRole.parent,
    UserRole.coach,
  ];

  bool loading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final auth = context.read<AuthProvider>();

      await auth.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        role: selectedRole.label,
      );

      if (!mounted) return;

      context.go('/verify-email');
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
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Form(
                key: _formKey,

                child: Column(
                  children: [
                    const AuthHeader(
                      title: "Create Account",
                      subtitle: "Join Croc City Football Academy",
                    ),

                    const SizedBox(height: 30),

                    AuthTextField(
                      controller: firstNameController,
                      label: "First Name",
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "First name is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: lastNameController,
                      label: "Last Name",
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Last name is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }

                        final emailRegex = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+$',
                        );

                        if (!emailRegex.hasMatch(value.trim())) {
                          return "Enter a valid email address";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Phone number is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Register As",
                        prefixIcon: Icon(Icons.groups),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(role.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    PasswordTextField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }

                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    PasswordTextField(
                      controller: confirmPasswordController,
                      label: "Confirm Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }

                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    AuthButton(
                      text: "CREATE ACCOUNT",
                      loading: loading,
                      onPressed: register,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),

                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text("Login"),
                        ),
                      ],
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