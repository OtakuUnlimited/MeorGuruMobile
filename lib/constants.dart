import 'package:flutter/material.dart';

class AppColors {
  static const Color orangeMain = Color(0xFFFF6600);
  static const Color maroonRed = Color(0xFFC3242B);
  static const Color bg = Color(0xFFF9F9F9);
  static const Color greenAccent = Color(0xFF6BBA45);
  static const Color brownAccent = Color(0xFF594136);
  static const Color textDark = Color(0xFF212121);
  static const Color borderGray = Color(0xFFE0E0E0);
}

Widget buildOutlineTextField(
  String label,
  String hint, {
  bool isObscure = false,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    obscureText: isObscure,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      hintText: hint,
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
    ),
  );
}
