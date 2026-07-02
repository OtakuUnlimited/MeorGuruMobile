import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../backend/services/auth_service.dart';
import '../components/contact_details_section.dart';
import '../components/location_details_section.dart';


import '../../routes/app_routes.dart';
import '../components/top_nav_bar.dart'; // Adjust based on your file path

class BasicDetailsScreen extends StatefulWidget {
  final int userId;

  const BasicDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController(); // Present in visual design
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController suburbController = TextEditingController();
  final TextEditingController postCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController(text: '+977');
  final TextEditingController phoneController = TextEditingController();

  String? selectedCountry;
  String? selectedGender;
  String? selectedState;

  bool isLoading = true;
  bool isSaving = false;
  
  List<dynamic> countries = [];
  List<String> states = [];

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final String response =
          await rootBundle.loadString(
        'lib/assets/json/state.json',
      );

      countries = json.decode(response);
      print(countries.first);
      print(countries.first['states']);
      countries = json.decode(response);

      print("Countries count: ${countries.length}");
      print(countries.first);
      if (countries.isNotEmpty) {
        selectedCountry = countries.first['name'];

       states = (countries.first['states'] as List<dynamic>)
        .map<String>((e) => e['name'].toString())
        .toList();

        selectedState = states.isNotEmpty ? states.first : null;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveDetails() async {
    if (firstNameController.text.trim().isEmpty) {
      _showError("Enter first name");
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      _showError("Enter last name");
      return;
    }

    if (selectedCountry == null) {
      _showError("Select country");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response =
    await AuthService().storeBasicDetails({
        "user_id": widget.userId,
        "first_name": firstNameController.text.trim(),
        "middle_name": middleNameController.text.trim(),
        "last_name": lastNameController.text.trim(),

        "gender": selectedGender,
        "country": selectedCountry,
        "state": selectedState,

        "suburb": suburbController.text.trim(),
        "postal_code": postCodeController.text.trim(),
        "address": addressController.text.trim(),

        "phone": phoneController.text.trim(),
        "country_code": countryCodeController.text.trim(),
      });

      if (response['success'] == true) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    suburbController.dispose();
    postCodeController.dispose();
    addressController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    await AuthService.logout();

    if (!mounted) return false;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    return false;
  },
  child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0531A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // First & Middle Name Row
                  Row(
                    children: [
                      Expanded(child: _buildTextField('FIRST NAME*', firstNameController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('MIDDLE NAME', middleNameController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('LAST NAME*', lastNameController),

                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Gender',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gender Selector Field Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGender,
                        hint: const Text('Select your gender', style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                 const SizedBox(height: 24),

                LocationDetailsSection(
                    enabled: true,
                  suburbController: suburbController,
                  postCodeController: postCodeController,
                  addressController: addressController,
                  onCountryChanged: (country, state) {
                    selectedCountry = country;
                    selectedState = state;
                  },
                ),

                const SizedBox(height: 24),

                ContactDetailsSection(
                    enabled: true,
                  phoneController: phoneController,
                  countryCodeController: countryCodeController,
                ),

                const SizedBox(height: 32),

                  // Process Validation and Save Button Frame Action Control
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSaving ? null : saveDetails,
                      child: isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Save Profile Details',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        await AuthService.logout();

                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: const Color(0xFFF1F3F5),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

}