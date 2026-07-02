import 'package:flutter/material.dart';
import '../../../constants.dart';

class ProfileNameSection extends StatelessWidget {
  final bool enabled;
  final TextEditingController firstNameC;
  final TextEditingController middleNameC;
  final TextEditingController lastNameC;
  final TextEditingController usernameC;

  const ProfileNameSection({
    super.key,
    required this.firstNameC,
    required this.middleNameC,
    required this.lastNameC,
    required this.usernameC,
    this.enabled = false,
  });

  Widget _buildInputLabelField(
    String label,
    TextEditingController c,
    bool enabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          enabled: enabled,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputLabelField(
                "FIRST NAME",
                firstNameC,
                enabled,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputLabelField(
                "MIDDLE NAME",
                middleNameC,
                enabled,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInputLabelField(
                "LAST NAME",
                lastNameC,
                enabled,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputLabelField(
                "USERNAME",
                usernameC,
                enabled,
              ),
            ),
          ],
        ),
      ],
    );
  }
}