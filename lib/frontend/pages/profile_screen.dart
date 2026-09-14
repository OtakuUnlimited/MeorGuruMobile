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

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

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

    // Create a local variable so Dart knows it is not null
    final profile = user;

    if (profile != null) {
      // ============================================================
      // NAME
      // ============================================================

      firstNameController.text =
          profile['first_name']?.toString() ?? '';

      middleNameController.text =
          profile['middle_name']?.toString() ?? '';

      lastNameController.text =
          profile['last_name']?.toString() ?? '';

      usernameController.text =
          profile['username']?.toString() ?? '';

      // ============================================================
      // CONTACT
      // ============================================================

      phoneController.text =
          profile['phone']?.toString() ?? '';

      String countryCode =
          profile['country_code']?.toString() ?? '';

      // Remove + if the database contains +977, +61, etc.
      countryCode =
          countryCode.replaceAll('+', '').trim();

      // If the stored code has more than 3 digits,
      // use 1 so the phone field does not crash.
      if (countryCode.length > 3) {
        countryCode = '1';
      }

      countryCodeController.text = countryCode;

      emailController.text =
          profile['email']?.toString() ?? '';

      // ============================================================
      // LOCATION
      // ============================================================

      suburbC.text =
          profile['suburb']?.toString() ?? '';

      postalC.text =
          profile['postal_code']?.toString() ?? '';

      addressC.text =
          profile['address']?.toString() ?? '';

      selectedCountry =
          profile['country'];

      selectedState =
          profile['state'];
    }
  } catch (e) {
    debugPrint("PROFILE LOAD ERROR: $e");
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


Future<void> _saveProfileWithValidation() async {
  // Run all Form validators
  final isValid = _profileFormKey.currentState?.validate() ?? false;

  if (!isValid) {
    // Show popup error
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text('Invalid Information'),
            ],
          ),
          content: const Text(
            'Please check the highlighted fields and correct the information before saving your profile.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.orangeMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return;
  }

  // Everything is valid
  await saveProfile();
}


    Future<void> saveProfile() async {
  if (user == null) return;

  try {
    setState(() {
      isSaving = true;
    });

    // Get country code and remove +
    String countryCode = countryCodeController.text
        .replaceAll('+', '')
        .trim();

    // If country code has more than 3 digits,
    // save it as 1
    if (countryCode.length > 3) {
      countryCode = '1';
    }

    final response = await _authService.updateProfile(
      {
        "user_id": user!['id'],

        // Name
        "first_name": firstNameController.text.trim(),
        "middle_name": middleNameController.text.trim(),
        "last_name": lastNameController.text.trim(),

        // Location
        "country": selectedCountry,
        "state": selectedState,
        "suburb": suburbC.text.trim(),
        "postal_code": postalC.text.trim(),
        "address": addressC.text.trim(),

        // Contact
        "phone": phoneController.text.trim(),

        // IMPORTANT:
        // Use the cleaned countryCode variable
        "country_code": countryCode,
      },
      _selectedImage,
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
            response['message']?.toString() ??
                "Unable to update profile.",
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to update profile: $e",
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}
  
  String? _getAvatarUrl(dynamic avatar) {
  if (avatar == null || avatar.toString().isEmpty) {
    return null;
  }

  String avatarName = avatar.toString();

  if (avatarName.startsWith('http')) {
    return avatarName;
  }

  if (avatarName.contains('127.0.0.1:8000')) {
    avatarName = avatarName.replaceFirst(
      '127.0.0.1:8000',
      '10.0.2.2:8000',
    );
  }

  return 'http://10.0.2.2:8000/uploads/users/$avatarName';
}

   @override
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
      body: Form(
      key: _profileFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Settings button

            // Profile image
            ProfileImageSection(
              imageUrl: _getAvatarUrl(user?['avatar']),
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
                          await _saveProfileWithValidation();
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
      ),
    );
  }
}