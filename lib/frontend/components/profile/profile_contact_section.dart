import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../constants.dart';

class ContactDetailsSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController countryCodeController;
  final bool enabled;

  const ContactDetailsSection({
    super.key,
    required this.phoneController,
    required this.countryCodeController,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    AppColors.orangeMain.withOpacity(0.1),
                child: const Icon(
                  Icons.phone_outlined,
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

          const Text(
            "PHONE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          IntlPhoneField(
            controller: phoneController,

            enabled: enabled,

            initialCountryCode: 'NP',

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.orangeMain,
                ),
              ),
            ),

            onCountryChanged: (country) {
              // Store ONLY the numeric code.
              // Example: 977 instead of +977 or ++977
              countryCodeController.text = country.dialCode;
            },

            validator: (phone) {
              // Empty number is allowed.
              if (phone == null ||
                  phone.number.trim().isEmpty) {
                return null;
              }

              // Validate against the selected country.
              if (!phone.isValidNumber()) {
                return "Invalid phone number for this country";
              }

              return null;
            },

            onChanged: (phone) {
              // Always keep database value as:
              // 977
              // NOT +977
              // NOT ++977
              countryCodeController.text =
                  phone.countryCode;
            },
          ),

          const SizedBox(height: 16),

          const Text(
            "EMAIL",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          TextFormField(
            enabled: enabled,
            controller: TextEditingController(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
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
      ),
    );
  }
}