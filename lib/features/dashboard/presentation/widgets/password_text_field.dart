import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.label = "Password",
    this.validator,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
      ),
    );
  }
}