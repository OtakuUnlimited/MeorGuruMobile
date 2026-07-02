import 'package:flutter/material.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/content_services.dart';
import '../../constants.dart';
import '../../routes/app_routes.dart';

import '../components/top_nav_bar.dart';

import '../components/profile/profile_name_section.dart';
import '../components/location_details_section.dart';
import '../components/contact_details_section.dart';
import '../components/profile/profile_image_section.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ContentService _contentService = ContentService();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  // Name
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();

  // Location
  final suburbC = TextEditingController();
  final postalC = TextEditingController();
  final addressC = TextEditingController();

  // Contact
  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController();
  final emailController = TextEditingController();

  List<dynamic> countries = [];
  List<String> states = [];

  String? selectedCountry;
  String? selectedState;

  bool isLoading = true;
  bool isSaving = false;

  // NEW
  bool isEditing = false;

  Map<String, dynamic>? user;
    @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await _authService.getProfile();

      print("PROFILE RESPONSE => $response");

      user = response;

      final countryData =
          await _contentService.fetchCountries();

      countries = countryData;

      if (user != null) {
        // Name
        firstNameController.text =
            user?['first_name'] ?? '';

        middleNameController.text =
            user?['middle_name'] ?? '';

        lastNameController.text =
            user?['last_name'] ?? '';

        usernameController.text =
            user?['username'] ?? '';

        // Contact
        phoneController.text =
            user?['phone'] ?? '';

        countryCodeController.text =
        (user?['country_code'] ?? '+977')
          .toString()
          .replaceAll('++', '+');

        emailController.text =
            user?['email'] ?? '';

        // Location
        suburbC.text =
            user?['suburb'] ?? '';

        postalC.text =
            user?['postal_code'] ?? '';

        addressC.text =
            user?['address'] ?? '';

        selectedCountry =
            user?['country'];

        selectedState =
            user?['state'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickProfileImage() async {
  if (!isEditing) return;

  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(context);

                final image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );

                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(context);

                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );

                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

    Future<void> saveProfile() async {
    if (user == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final response =
          await _authService.updateProfile(
            {
        "user_id": user!['id'],

        // Name
        "first_name":
            firstNameController.text.trim(),

        "middle_name":
            middleNameController.text.trim(),

        "last_name":
            lastNameController.text.trim(),

        // Location
        "country": selectedCountry,
        "state": selectedState,

        "suburb":
            suburbC.text.trim(),

        "postal_code":
            postalC.text.trim(),

        "address":
            addressC.text.trim(),

        // Contact
        "phone":
            phoneController.text.trim(),

        "country_code":
            countryCodeController.text.trim(),
      }, _selectedImage,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Profile updated successfully",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'].toString(),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }  @override
  void dispose() {
    // Name
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();

    // Location
    suburbC.dispose();
    postalC.dispose();
    addressC.dispose();

    // Contact
    phoneController.dispose();
    countryCodeController.dispose();
    emailController.dispose();

    super.dispose();
  }  
    @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomTopNavBar(
        title: "Profile",
        style: NavBarStyle.BrandedLight,
        showSettings: true,
        showBookings: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Settings button

            // Profile image
            ProfileImageSection(
              imageUrl: user?['profile_image'],
              selectedImage: _selectedImage,
              editable: isEditing,
              onTap: pickProfileImage,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
            ),

            const SizedBox(height: 24),

            // Name section
            ProfileNameSection(
              firstNameC: firstNameController,
              middleNameC: middleNameController,
              lastNameC: lastNameController,
              usernameC: usernameController,
              enabled: isEditing,
            ),

            const SizedBox(height: 24),
                        // Location section
            LocationDetailsSection(
              enabled: isEditing,
              initialCountry: selectedCountry,
              initialState: selectedState,
              suburbController: suburbC,
              postCodeController: postalC,
              addressController: addressC,

              onCountryChanged: (
                String? country,
                String? state,
              ) {
                setState(() {
                  selectedCountry = country;
                  selectedState = state;
                });
              },
            ),

            const SizedBox(height: 24),

            // Contact section
            ContactDetailsSection(
              enabled: isEditing,
              phoneController: phoneController,
              countryCodeController:
                  countryCodeController,
            ),

            const SizedBox(height: 30),
                        // Edit / Save button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroonRed,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!isEditing) {
                          setState(() {
                            isEditing = true;
                          });
                        } else {
                          await saveProfile();
                        }
                      },
                child: isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        isEditing
                            ? "SAVE PROFILE"
                            : "EDIT PROFILE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (isEditing) {
                    setState(() {
                      isEditing = false;
                    });

                    loadData(); // reload original values
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isEditing
                      ? "CANCEL EDIT"
                      : "BACK",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.maroonRed,
                ),
                onPressed: () async {
                  final confirm =
                      await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                        "Are you sure you want to logout?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context, false),
                          child:
                              const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context, true),
                          child:
                              const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await AuthService.logout();

                    if (!mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}