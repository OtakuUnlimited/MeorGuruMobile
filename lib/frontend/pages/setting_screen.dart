import 'package:flutter/material.dart';
import '../../backend/services/auth_service.dart'; // Adjust path setup matching your service layers 
import '../components/top_nav_bar.dart'; 
import '../components/confirm_password_field.dart';
import '../components/password_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService(); // Contains your integrated changePassword method helper

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Client-side quick checks logic blocks
    if (oldPassword.isEmpty) {
      _showSnackBar("Please enter your old password", Colors.red);
      return;
    }
    if (newPassword.isEmpty) {
      _showSnackBar("Please enter your new password", Colors.red);
      return;
    }
    if (newPassword.length < 6) {
      _showSnackBar("New password must be at least 6 characters", Colors.red);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackBar("Passwords do not match", Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Calls your defined Future<dynamic> changePassword execution service mapping
      final response = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      // Handle raw map status parameter rules based on Laravel controller validation map callbacks 
      final int statusCode = response['status'] ?? 400;

      if (statusCode == 200) {
        _showSnackBar(response['message'] ?? 'Password changed successfully.', Colors.green);
        
        // Wipe forms fields inputs completely upon success execution trace 
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else if (statusCode == 400 && response['errors'] != null) {
        // Parse validation dictionary lists returning dynamic failure string rows
        final Map<String, dynamic> validationErrors = response['errors'];
        String firstError = 'Validation failed.';
        if (validationErrors.values.isNotEmpty) {
          var errList = validationErrors.values.first;
          if (errList is List && errList.isNotEmpty) {
            firstError = errList.first.toString();
          } else {
            firstError = errList.toString();
          }
        }
        _showSnackBar(firstError, Colors.red);
      } else {
        _showSnackBar(response['message'] ?? 'Password update failed.', Colors.red);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

Future<void> deleteAccount() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
        "Are you sure you want to permanently delete your account?\n\nThis action cannot be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  setState(() {
    _isSaving = true;
  });

  try {
    final response = await _authService.deleteCurrentRole();

    if (!mounted) return;

    if (response['status'] == true) {
      await AuthService.logout();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } else {
      _showSnackBar(
        response['message'] ?? "Delete failed",
        Colors.red,
      );
    }
  } catch (e) {
    _showSnackBar(
      "Error: $e",
      Colors.red,
    );
  }

  if (mounted) {
    setState(() {
      _isSaving = false;
    });
  }
}

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Big Title header block
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0531A), // Orange Header token
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Form inputs mapping blocks
            PasswordField(
              controller: _oldPasswordController,
              label: 'Old Password',
              hint: '',
            ),
            const SizedBox(height: 20),
            PasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              hint: '',
              showValidation: false, // Set to true if you want the checklist criteria displayed below the container box field.
            ),
            const SizedBox(height: 20),
            ConfirmPasswordField(
              passwordController: _newPasswordController,
              confirmController: _confirmPasswordController,
            ),
            const SizedBox(height: 40),

            // Action triggers execution stack wrapper
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Dark Red 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Outlined Custom Cancel Actions Box element
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danger Account Discard Action execution block
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : deleteAccount,
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}