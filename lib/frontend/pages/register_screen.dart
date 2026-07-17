import 'package:flutter/material.dart';

import '../../constants.dart';
import '../components/top_nav_bar.dart';
import '../../backend/services/auth_service.dart';
import '../components/password_field.dart';
import '../components/confirm_password_field.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  final AuthService _authService = AuthService();

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool agreeTerms = false;
  bool isLoading = false;

  late TapGestureRecognizer termsRecognizer;
  late TapGestureRecognizer privacyRecognizer;

  Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw "Could not launch $url";
  }
}
@override
void initState() {
  super.initState();

  termsRecognizer = TapGestureRecognizer()
    ..onTap = () {
      _openUrl(
        "https://meroguru.com/page/terms-and-conditions",
      );
    };

  privacyRecognizer = TapGestureRecognizer()
    ..onTap = () {
      _openUrl(
        "https://meroguru.com/page/privacy-policy",
      );
    };
}
  

  Future<void> register() async {
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a username"),
        ),
      );
      return;
    }
    

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an email"),
        ),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a password"),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please accept Terms and Conditions",
          ),
        ),
      );
      return;
    }
    final password = passwordController.text;

    final validPassword =
        password.length >= 8 &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[@$!%*#?&]').hasMatch(password);

    if (!validPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must contain at least 8 characters, uppercase, lowercase, number and special character.",
          ),
        ),
      );
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });

      final result = await _authService.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        userType: "customer",
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final user =
        result['data']['user'];

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'userId': user['id'],
            'email': emailController.text.trim(),
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Registration successful',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        String errorMessage;

        if (result['message'] is Map) {
          errorMessage =
              (result['message'] as Map)
                  .values
                  .expand((e) => e as List)
                  .join('\n');
        } else {
          errorMessage =
              result['message']?.toString() ??
              'Registration failed';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    termsRecognizer.dispose();
   privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const CustomTopNavBar(
        title: "",
        showBack: true,
        style: NavBarStyle.TransAuth,
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
                            children: [
                              const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orangeMain,
                                ),
                              ),

                              const SizedBox(height: 24),

                              buildOutlineTextField(
                                "Username",
                                "Enter Username",
                                controller:
                                    usernameController,
                              ),

                              const SizedBox(height: 16),

                              buildOutlineTextField(
                                "Email",
                                "Enter Email",
                                controller: emailController,
                              ),

                              const SizedBox(height: 16),

                              PasswordField(
                                controller: passwordController,
                                label: "Password",
                                hint: "Enter Password",
                                showValidation: true,
                              ),

                              const SizedBox(height: 16),

                              ConfirmPasswordField(
                                passwordController: passwordController,
                                confirmController:
                                    confirmPasswordController,
                              ),

                              const SizedBox(height: 16),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: agreeTerms,
                                    activeColor: AppColors.orangeMain,
                                    onChanged: (value) {
                                      setState(() {
                                        agreeTerms = value ?? false;
                                      });
                                    },
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text.rich(
                                        TextSpan(
                                          text: "I agree to the ",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textDark,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Terms and Conditions",
                                              style: const TextStyle(
                                                color: AppColors.orangeMain,
                                                decoration: TextDecoration.underline,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              recognizer: termsRecognizer,
                                            ),
                                            const TextSpan(text: " and "),
                                            TextSpan(
                                              text: "Privacy Policy",
                                              style: const TextStyle(
                                                color: AppColors.orangeMain,
                                                decoration: TextDecoration.underline,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              recognizer: privacyRecognizer,
                                            ),
                                            const TextSpan(text: "."),
                                          ],
                                        ),
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
                                  style:
                                      ElevatedButton.styleFrom(
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
                                      : register,
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
                                          "REGISTER",
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

                              const SizedBox(height: 16),

                              GestureDetector(
                                onTap: () =>
                                    Navigator.pop(context),
                                child: const Text.rich(
                                  TextSpan(
                                    text:
                                        "Already have an account? ",
                                    style: TextStyle(
                                      color:
                                          AppColors.textDark,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Sign in",
                                        style: TextStyle(
                                          color: AppColors
                                              .orangeMain,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      )
                                    ],
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