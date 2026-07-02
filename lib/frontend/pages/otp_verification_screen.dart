import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../backend/services/auth_service.dart';
import '../components/top_nav_bar.dart'; // Adjust path based on your file structure

class OtpVerificationScreen extends StatefulWidget {
  final int userId;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter OTP'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _authService.verifyOtp(
        userId: widget.userId,
        otp: otpController.text.trim(),
      );

      if (!mounted) return;

      if (result['status'] == true) {
        final user = result['data'];

        final bool missingBasicDetails =
            (user['first_name'] == null ||
                user['first_name'].toString().trim().isEmpty) ||
            (user['last_name'] == null ||
                user['last_name'].toString().trim().isEmpty) ||
            (user['country'] == null ||
                user['country'].toString().trim().isEmpty);

        if (missingBasicDetails) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.basicDetails,
            arguments: user['id'],
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'OTP verification failed',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    await AuthService.logout();

    if (!mounted) return false;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    return false;
  },
  child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0531A), // Branded Orange tint
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter the OTP sent to ${widget.email}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ENTER OTP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Input Row Layout containing inline Resend Trigger button frame
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF1F3F5),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828), // Dark UI Red
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: isLoading ? null : () {
                      // Trigger your Resend Backend OTP task pipeline here
                    },
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Execution submission action frame button
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
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Termination processing widget action item
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
                onPressed: isLoading
                    ? null
                    : () async {
                        await AuthService.logout();

                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
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
          ],
        ),
      ),
    ),
    );
  }
}