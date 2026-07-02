import 'package:flutter/material.dart';

import '../../constants.dart';
import '../components/top_nav_bar.dart';
import 'register_screen.dart';
import '../../backend/services/auth_service.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool rememberMe = false;
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
        ),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['data'];

        final bool isVerified =
            user['email_or_otp_verified'] == 1;

        final bool missingBasicDetails =
          user['verification_step'] == 1; 

        if (!isVerified) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.otpVerification,
            arguments: {
              'userId': user['id'],
              'email': emailController.text.trim(),
            },
          );
        } else if (missingBasicDetails) {
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
              result['message'] ?? 'Login failed',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const CustomTopNavBar(
        title: "",
        style: NavBarStyle.TransAuth,
        showBack: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'lib/assets/images/main-logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 120),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 24,
                            bottom: 40,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.orangeMain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              buildOutlineTextField(
                                "Email",
                                "Enter Email",
                                controller: emailController,
                              ),

                              const SizedBox(height: 20),

                              TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Enter Password",
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
                                ),
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
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        activeColor:
                                            AppColors.orangeMain,
                                        onChanged: (value) {
                                          setState(() {
                                            rememberMe =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Remember me",
                                        style: TextStyle(
                                          color:
                                              AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color:
                                            AppColors.orangeMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.maroonRed,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        25,
                                      ),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : login,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              const Spacer(),

                              const SizedBox(height: 24),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text.rich(
                                    TextSpan(
                                      text:
                                          "Don't have an account? ",
                                      style: TextStyle(
                                        color:
                                            AppColors.textDark,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Sign up",
                                          style: TextStyle(
                                            color: AppColors
                                                .orangeMain,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}