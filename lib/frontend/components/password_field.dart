import 'package:flutter/material.dart';
import '../../constants.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool showValidation;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.showValidation = false,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool obscureText = true;

  bool hasMinLength = false;
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(validatePassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(validatePassword);
    super.dispose();
  }

  void validatePassword() {
    String password = widget.controller.text;

    setState(() {
      hasMinLength = password.length >= 8;
      hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecialChar =
          RegExp(r'[@$!%*#?&]').hasMatch(password);
    });
  }

  Widget rule(String text, bool valid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "${valid ? '✔' : '✖'} $text",
        style: TextStyle(
          color: valid ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
        controller: widget.controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(
            color: Colors.black54,
          ),
          hintText: widget.hint,
          floatingLabelBehavior:
              FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: AppColors.orangeMain,
              width: 2,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        ),
      ),

        if (widget.showValidation &&
            widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                rule(
                    "Minimum 8 characters",
                    hasMinLength),
                rule(
                    "One lowercase letter",
                    hasLowercase),
                rule(
                    "One uppercase letter",
                    hasUppercase),
                rule("One number", hasNumber),
                rule(
                  "One special character (@\$!%*#?&)",
                  hasSpecialChar,
                ),
              ],
            ),
          ),
      ],
    );
  }
}