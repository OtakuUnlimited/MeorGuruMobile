import 'package:flutter/material.dart';

import '../../backend/services/auth_service.dart';
import '../../routes/app_routes.dart';

Future<bool> requireLogin(
  BuildContext context, {
  String message =
      'Please log in to continue.',
}) async {
  final isLoggedIn =
      await AuthService.isLoggedIn();

  if (!context.mounted) {
    return false;
  }

  if (isLoggedIn) {
    return true;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

  await Navigator.pushNamed(
    context,
    AppRoutes.login,
  );

  return false;
}