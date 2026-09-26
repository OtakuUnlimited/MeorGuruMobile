import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../backend/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../components/password_field.dart';
import 'package:flutter/services.dart';
class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _emailController =
      TextEditingController();

  final List<TextEditingController> _otpControllers =
    List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  final TextEditingController
      _newPasswordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _emailController.dispose();
     for (final controller in _otpControllers) {
    controller.dispose();
  }

  for (final focusNode in _otpFocusNodes) {
    focusNode.dispose();
  }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  String get _enteredOtp =>
    _otpControllers.map((controller) => controller.text).join();

void _clearOtp() {
  for (final controller in _otpControllers) {
    controller.clear();
  }

  if (_otpFocusNodes.isNotEmpty) {
    _otpFocusNodes.first.requestFocus();
  }
}

void _showError(String message) {
  if (!mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message
              .replaceFirst('Exception: ', '')
              .replaceFirst('HttpException: ', ''),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

Widget _buildOtpFields() {
  return Row(
    children: List.generate(6, (index) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: index == 5 ? 0 : 8,
          ),
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textInputAction: index == 5
                ? TextInputAction.done
                : TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '0',
              hintStyle: const TextStyle(
                color: Color(0xFFB8B8B8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFCACACA),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5A00),
                  width: 1.6,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }

              if (index == 5 && value.isNotEmpty) {
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ),
      );
    }),
  );
}

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@'
      r'[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ============================================================
  // OTP VALIDATION
  // ============================================================

  String? _validateOtp(String? value) {
    if (!_otpSent) return null;

    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Please enter the OTP';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must contain 6 digits';
    }

    return null;
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  bool _isStrongPassword(
    String password,
  ) {
    final hasMinimumLength =
        password.length >= 8;

    final hasLowercase =
        RegExp(r'[a-z]').hasMatch(
      password,
    );

    final hasUppercase =
        RegExp(r'[A-Z]').hasMatch(
      password,
    );

    final hasNumber =
        RegExp(r'[0-9]').hasMatch(
      password,
    );

    final hasSpecialCharacter =
        RegExp(r'[@$!%*#?&]').hasMatch(
      password,
    );

    return hasMinimumLength &&
        hasLowercase &&
        hasUppercase &&
        hasNumber &&
        hasSpecialCharacter;
  }

  // ============================================================
  // SEND OR RESEND OTP
  // ============================================================

  Future<void> _sendOtp({
    bool resend = false,
  }) async {
    FocusScope.of(context).unfocus();

    if (_isLoading || _isResending) {
      return;
    }

    final email =
        _emailController.text.trim();

    final emailError =
        _validateEmail(email);

    if (emailError != null) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      if (resend) {
        _isResending = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      debugPrint(
        '========== SEND OTP REQUEST ==========',
      );

      debugPrint(
        'Email: $email',
      );

      final dynamic response =
          await _authService
              .forgotPassword(email);

      debugPrint(
        '========== SEND OTP RESPONSE ==========',
      );

      debugPrint(
        'Response type: ${response.runtimeType}',
      );

      debugPrint(
        'Full response: $response',
      );

      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _clearOtp();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      final String message =
          response is Map
              ? response['message']
                      ?.toString() ??
                  'OTP has been sent to your email.'
              : 'OTP has been sent to your email.';

      _showMessage(
        resend
            ? 'A new OTP has been sent to your email.'
            : message,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========== SEND OTP ERROR ==========',
      );

      debugPrint(
        'Error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      _showMessage(
        _readableError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isResending = false;
        });
      }
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _confirmPassword() async {
    FocusScope.of(context).unfocus();

    if (_isLoading || !_otpSent) {
      return;
    }

    final email =
        _emailController.text.trim();

    final otp = _enteredOtp;

if (otp.length != 6 ||
    !RegExp(r'^\d{6}$').hasMatch(otp)) {
  _showError('Please enter the complete 6-digit OTP.');

  final firstEmptyIndex = _otpControllers.indexWhere(
    (controller) => controller.text.isEmpty,
  );

  _otpFocusNodes[
    firstEmptyIndex == -1 ? 0 : firstEmptyIndex
  ].requestFocus();

  return;
}

    final newPassword =
        _newPasswordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    final otpError = _validateOtp(otp);

    if (otpError != null) {
      _formKey.currentState?.validate();
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage(
        'Please enter a new password.',
        isError: true,
      );
      return;
    }

    if (!_isStrongPassword(newPassword)) {
      _showMessage(
        'The new password does not meet all password requirements.',
        isError: true,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your new password.',
        isError: true,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'The passwords do not match.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        '========== RESET PASSWORD REQUEST ==========',
      );

      debugPrint(
        'Email: $email',
      );

      debugPrint(
        'OTP: $otp',
      );

      final dynamic response =
          await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      debugPrint(
        '========== RESET PASSWORD RESPONSE ==========',
      );

      debugPrint(
        'Response type: ${response.runtimeType}',
      );

      debugPrint(
        'Full response: $response',
      );

      if (!mounted) return;

      final String message =
          response is Map
              ? response['message']
                      ?.toString() ??
                  'Password reset successfully.'
              : 'Password reset successfully.';

      _showMessage(message);

      await Future<void>.delayed(
        const Duration(
          milliseconds: 600,
        ),
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========== RESET PASSWORD ERROR ==========',
      );

      debugPrint(
        'Error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      _showMessage(
        _readableError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Future<void> _handlePrimaryButton() {
    if (_otpSent) {
      return _confirmPassword();
    }

    return _sendOtp();
  }

  String get _buttonText {
    return _otpSent
        ? 'Confirm Password'
        : 'Send OTP';
  }

  String get _instructions {
    if (_otpSent) {
      return 'Enter the OTP sent to your email and create a new password.';
    }

    return 'Enter your registered email address and we will send you a verification OTP.';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
  }

  // ============================================================
  // READABLE ERROR
  // ============================================================

  String _readableError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .replaceFirst(
          'Network request failed: ',
          '',
        )
        .replaceFirst(
          'HttpException: ',
          '',
        );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      hintStyle: const TextStyle(
        color: Color(0xFF737B85),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF737B85),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFCACACA),
        ),
      ),
      disabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFFF5A00),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF222B38),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  36,
                  42,
                  36,
                  36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Color(0x16000000),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      const Text(
                        'Forgot Password',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Color(0xFF222B38),
                          fontSize: 32,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        _instructions,
                        textAlign:
                            TextAlign.center,
                        style: const TextStyle(
                          color:
                              Color(0xFF68717D),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      const Text(
                        'Email Address',
                        style: TextStyle(
                          color:
                              Color(0xFF68717D),
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller:
                            _emailController,
                        enabled:
                            !_otpSent &&
                                !_isLoading,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        textInputAction:
                            TextInputAction
                                .done,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        validator:
                            _validateEmail,
                        onFieldSubmitted: (_) {
                          if (!_otpSent) {
                            _sendOtp();
                          }
                        },
                        decoration:
                            _inputDecoration(
                          hint:
                              'Enter your email',
                          icon: Icons
                              .email_outlined,
                        ),
                      ),

                      if (_otpSent) ...[
                      const SizedBox(height: 32),

                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: Color(0xFF68717D),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildOtpFields(),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isResending
                              ? null
                              : () async {
                                  _clearOtp();
                                  await _sendOtp(resend: true);
                                },
                          child: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFF5A00),
                                  ),
                                )
                              : const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Color(0xFFFF5A00),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      PasswordField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        hint: 'Enter your new password',
                        showValidation: true,
                      ),

                      const SizedBox(height: 28),

                      PasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your new password',
                      ),

                      const SizedBox(height: 32),
                    ],

                      const SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _handlePrimaryButton,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFFF5A00,
                            ),
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                const Color(
                              0xFFFFA675,
                            ),
                            disabledForegroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(6),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : Text(
                                  _buttonText,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      TextButton(
                        onPressed:
                            _isLoading ||
                                    _isResending
                                ? null
                                : () {
                                    Navigator
                                        .maybePop(
                                      context,
                                    );
                                  },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color:
                                Color(0xFFFF5A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}