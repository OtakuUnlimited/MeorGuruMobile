import 'package:flutter/material.dart';
import '../../../constants.dart';

class ProfileLocationSection extends StatelessWidget {
  final List<dynamic> countries;
  final List<String> states;

  final String? selectedCountry;
  final String? selectedState;

  final Function(String?) onCountryChanged;
  final Function(String?) onStateChanged;

  final TextEditingController suburbC;
  final TextEditingController postalC;
  final TextEditingController addressC;

  const ProfileLocationSection({
    super.key,
    required this.countries,
    required this.states,
    required this.selectedCountry,
    required this.selectedState,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.suburbC,
    required this.postalC,
    required this.addressC,
  });

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
              Text(
                heading,
                style: const TextStyle(
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

  Widget _buildDropdownRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineInputRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileSectionCard(
      "Location Details",
      Icons.location_on_outlined,
      [
        _buildDropdownRow(
          "Country",
          selectedCountry ?? '',
        ),

        _buildDropdownRow(
          "State/Province",
          selectedState ?? '',
        ),

        _buildInlineInputRow(
          "Suburb/City",
          suburbC.text,
        ),

        _buildInlineInputRow(
          "Post Code",
          postalC.text,
          valueColor: AppColors.orangeMain,
        ),

        const SizedBox(height: 12),

        TextField(
          controller: addressC,
          decoration: const InputDecoration(
            labelText: "Full Address",
          ),
        ),
      ],
    );
  }
}