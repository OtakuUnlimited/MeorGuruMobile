import 'package:flutter/material.dart';
import '../../constants.dart';

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const ConfirmPasswordField({
    Key? key,
    required this.passwordController,
    required this.confirmController,
  }) : super(key: key);

  @override
  State<ConfirmPasswordField> createState() =>
      _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState
    extends State<ConfirmPasswordField> {
  bool obscureText = true;
  bool passwordsMatch = false;

  @override
  void initState() {
    super.initState();

    widget.passwordController.addListener(validate);
    widget.confirmController.addListener(validate);
  }

  void validate() {
    setState(() {
      passwordsMatch =
          widget.confirmController.text.isNotEmpty &&
          widget.passwordController.text ==
              widget.confirmController.text;
    });
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(validate);
    widget.confirmController.removeListener(validate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.confirmController,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            labelStyle: const TextStyle(color: Colors.black54),
            hintText: "Confirm Password",
            floatingLabelBehavior: FloatingLabelBehavior.always,
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

        const SizedBox(height: 8),

        if (widget.confirmController.text.isNotEmpty)
          Text(
            passwordsMatch
                ? "✔ Password matched"
                : "✖ Passwords must match",
            style: TextStyle(
              color:
                  passwordsMatch ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}