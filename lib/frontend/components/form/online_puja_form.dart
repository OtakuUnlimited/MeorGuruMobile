import 'package:flutter/material.dart';

import '../searchable_country_dropdown.dart';
import '../searchable_state_dropdown.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../gotra_dropdown.dart';

class OnlinePujaForm extends StatefulWidget {
  final VoidCallback onPaymentSubmit;
  const OnlinePujaForm({Key? key, required this.onPaymentSubmit}) : super(key: key);

  @override
  State<OnlinePujaForm> createState() => _OnlinePujaFormState();
}

class _OnlinePujaFormState extends State<OnlinePujaForm> {
  bool _agreedToTerms = false;
  String? _pujaBookingFor;
  String? _timezone;
  String? _caste;
  String? _gotra;
  String? _countryCode = '+977';
  String? deliveryCountry;
  String? deliveryState;
  String? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= CEREMONY DETAILS =================
          _buildSectionHeader('Ceremony Details'),
          
          _buildFieldLabel('Puja Booking for:'),
          _buildDropdownField(
            value: _pujaBookingFor,
            hint: 'Select',
            items: ['Myself', 'Family Member', 'Friend'],
            onChanged: (val) => setState(() => _pujaBookingFor = val),
          ),

          // Side-by-Side Row Exception 1: Date and Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Date of puja:'),
                    _buildTextField(
                      hintText: 'Date',
                      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFC62828), size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Time of puja:'),
                    _buildTextField(
                      hintText: '--:--',
                      suffixIcon: const Icon(Icons.access_time, color: Colors.black54, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildFieldLabel('Timezone:'),
          _buildDropdownField(
            value: _timezone,
            hint: 'Select Timezone',
            items: ['Nepal Time (NPT)', 'GMT +5:45', 'EST', 'AEST'],
            onChanged: (val) => setState(() => _timezone = val),
          ),
          const SizedBox(height: 12),

          // ================= PERSONAL INFORMATION =================
          _buildSectionHeader('Personal Information'),
          
          // Refactored to separate lines
          _buildFieldLabel('First Name:'),
          _buildTextField(),

          _buildFieldLabel('Last Name:'),
          _buildTextField(),

          _buildFieldLabel('Caste:', isRequired: false),
          _buildDropdownField(
            value: _caste,
            hint: 'Select',
            items: ['Brahman', 'Chhetri', 'Newar', 'Gurung', 'Other'],
            onChanged: (val) => setState(() => _caste = val),
          ),

          _buildFieldLabel('Gotra:', isRequired: false),
          _buildDropdownField(
            value: _gotra,
            hint: 'Select Gotra',
            items: ['Kashyap', 'Bharadwaj', 'Vasistha', 'Gautam', 'Shandilya'],
            onChanged: (val) => setState(() => _gotra = val),
          ),

          _buildFieldLabel('Email Address:'),
          _buildTextField(),

          // Side-by-Side Row Exception 2: Country Code and Phone Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Country Code:'),
                    _buildDropdownField(
                      value: _countryCode,
                      items: ['+977', '+61', '+1', '+44'],
                      onChanged: (val) => setState(() => _countryCode = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Phone No.:'),
                    _buildTextField(),
                  ],
                ),
              ),
            ],
          ),

          // Refactored to separate lines
          _buildFieldLabel('Country:'),
         Column(

            children: [
               SearchableCountryDropdown(
              label: "",
              initialCountry: _selectedCountry,
              onChanged: (country) {
                setState(() {
                  deliveryCountry = country;

                    if (country != "Australia") {
                        deliveryState = null;
                    }
                });
              },
              
            ),
            if (deliveryCountry == "Australia")
            const SizedBox(height: 16),

                  if (deliveryCountry == "Australia")
                  
                      SearchableStateDropdown(
                          country: "Australia",
                          initialState: deliveryState,
                          onChanged: (state) {

                              setState(() {
                                  deliveryState = state;
                              });

                          },
                      ),

              ],

          ),

          _buildFieldLabel('City/Suburb:', isRequired: false),
          _buildTextField(),

          _buildFieldLabel('Zip/Postal Code:'),
          _buildTextField(),

          _buildFieldLabel('Full Address:'),
          _buildTextField(),
          const SizedBox(height: 12),

          // ================= ADDITIONAL NOTES =================
          _buildSectionHeader('Additional Notes'),
          const SizedBox(height: 8),
          _buildTextField(
            maxLines: 4,
            hintText: 'Please include additional information, your wishes from the puja, sankalpa, or if you would like to include additional people in the puja (eg: your child)',
          ),
          const SizedBox(height: 20),

          // Terms and Conditions Acceptance Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreedToTerms,
                  activeColor: const Color(0xFFFA6400),
                  onChanged: (val) => setState(() => _agreedToTerms = val!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(text: 'I agree to the MeroGuru '),
                      TextSpan(text: 'Terms and Conditions ', style: TextStyle(color: Color(0xFFFA6400), fontWeight: FontWeight.w500)),
                      TextSpan(text: 'and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFFFA6400), fontWeight: FontWeight.w500)),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Pricing and Submission
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Payment Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('\$500', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2E2E), // Near black/dark charcoal aesthetic button
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: _agreedToTerms ? widget.onPaymentSubmit : null,
              child: const Text(
                'Debit or Credit Card',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFA6400)),
        ),
        const SizedBox(height: 6),
        const Divider(color: Colors.black12, thickness: 1, height: 10),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
          children: [
            TextSpan(text: label),
            if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFC62828))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({String? hintText, Widget? suffixIcon, int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFFA6400), width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null ? Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)) : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}