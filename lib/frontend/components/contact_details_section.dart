import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_pickers/country_pickers.dart';

class ContactDetailsSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController countryCodeController;
  final bool enabled;

  const ContactDetailsSection({
    super.key,
    required this.phoneController,
    required this.countryCodeController,
    this.enabled = false,
  });

    String getIsoFromDialCode(String dialCode) {
      dialCode = dialCode.replaceAll('++', '+');

      final country = CountryPickerUtils.getCountryByPhoneCode(
        dialCode.replaceAll('+', ''),
      );

      return country.isoCode;
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFFFEFEA),
                child: Icon(
                  Icons.phone_outlined,
                  color: Color(0xFFE0531A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Contact Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          IgnorePointer(
          ignoring: !enabled,
          child: IntlPhoneField(
            controller: phoneController,
            initialCountryCode:  getIsoFromDialCode(countryCodeController.text),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              filled: true,
              fillColor: const Color(0xFFF1F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (phone) {
              phoneController.text = phone.number;
              countryCodeController.text =
                  '+${phone.countryCode}';
            },
          ),
          ),
        ],
      ),
    );
  }
}