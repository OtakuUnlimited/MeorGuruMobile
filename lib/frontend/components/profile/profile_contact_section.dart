import 'package:flutter/material.dart';
import '../../../constants.dart';

class ProfileContactSection extends StatelessWidget {
  final TextEditingController phoneC;
  final TextEditingController emailC;

  const ProfileContactSection({
    super.key,
    required this.phoneC,
    required this.emailC,
  });

  Widget _buildInputLabelField(
    String label,
    TextEditingController c,
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

  Widget _buildProfileSectionCard(
    String heading,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    AppColors.orangeMain.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: AppColors.orangeMain,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Contact Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileSectionCard(
      "Contact Details",
      Icons.phone_outlined,
      [
        _buildInputLabelField(
          "PHONE",
          phoneC,
        ),

        const SizedBox(height: 16),

        _buildInputLabelField(
          "EMAIL",
          emailC,
        ),
      ],
    );
  }
}