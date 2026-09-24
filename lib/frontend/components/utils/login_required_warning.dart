import 'package:flutter/material.dart';

class LoginRequiredWarning
    extends StatelessWidget {
  final String message;
  final VoidCallback onLoginPressed;
  final bool loginLoading;

  const LoginRequiredWarning({
    super.key,
    required this.message,
    required this.onLoginPressed,
    this.loginLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const warningBackground =
        Color(0xFFFFF3CD);

    const warningBorder =
        Color(0xFFFFCA2C);

    const warningText =
        Color(0xFF664D03);

    const warningButton =
        Color(0xFFFFC107);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warningBackground,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: warningBorder,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: warningText,
            size: 27,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: warningText,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: loginLoading
                  ? null
                  : onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    warningButton,
                foregroundColor:
                    Colors.black87,
                disabledBackgroundColor:
                    warningButton
                        .withOpacity(0.6),
                disabledForegroundColor:
                    Colors.black54,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              child: loginLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    )
                  : const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}