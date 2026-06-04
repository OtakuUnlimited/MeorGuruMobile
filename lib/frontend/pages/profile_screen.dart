import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../backend/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool isLoading = true;
  bool isSaving = false;

  // Controllers (same fields as your UI)
  final firstNameC = TextEditingController();
  final middleNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final countryC = TextEditingController();
  final stateC = TextEditingController();
  final suburbC = TextEditingController();
  final postalC = TextEditingController();
  final addressC = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// =======================
  /// FETCH PROFILE FROM API
  /// =======================
  Future<void> loadProfile() async {
    try {
      final res = await _authService.getProfile();

      firstNameC.text = res['first_name'] ?? '';
      middleNameC.text = res['middle_name'] ?? '';
      lastNameC.text = res['last_name'] ?? '';
      usernameC.text = res['username'] ?? '';
      emailC.text = res['email'] ?? '';
      phoneC.text = res['phone'] ?? '';

      countryC.text = res['country'] ?? '';
      stateC.text = res['state'] ?? '';
      suburbC.text = res['suburb'] ?? '';
      postalC.text = res['postal_code'] ?? '';
      addressC.text = res['address'] ?? '';

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  /// =======================
  /// SAVE PROFILE TO API
  /// =======================
  Future<void> saveProfile() async {
    try {
      setState(() => isSaving = true);

      final res = await _authService.updateProfile(
        username: usernameC.text,
        email: emailC.text,
        phone: phoneC.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Profile updated"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  void dispose() {
    firstNameC.dispose();
    middleNameC.dispose();
    lastNameC.dispose();
    usernameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    countryC.dispose();
    stateC.dispose();
    suburbC.dispose();
    postalC.dispose();
    addressC.dispose();
    super.dispose();
  }

  // =======================
  // YOUR ORIGINAL WIDGETS (UNCHANGED STYLE)
  // =======================

  Widget _buildInputLabelField(String label, TextEditingController c) {
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
                child: Icon(icon,
                    color: AppColors.orangeMain),
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

  Widget _buildDropdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 14)),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Colors.grey),
            ],
          )
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomTopNavBar(
        title: "My Profile",
        style: NavBarStyle.BrandedLight,
        showMenu: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart,
                color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle,
                color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 60),
            ),

            const SizedBox(height: 12),

            Text(
              "${firstNameC.text} ${lastNameC.text}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildInputLabelField(
                      "FIRST NAME", firstNameC),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputLabelField(
                      "MIDDLE NAME", middleNameC),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInputLabelField(
                      "LAST NAME", lastNameC),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputLabelField(
                      "USERNAME", usernameC),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildProfileSectionCard(
              "Location Details",
              Icons.location_on_outlined,
              [
                _buildDropdownRow(
                    "Country", countryC.text),
                _buildDropdownRow(
                    "State/Province", stateC.text),
                _buildInlineInputRow(
                    "Suburb/City", suburbC.text),
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
            ),

            const SizedBox(height: 16),

            _buildProfileSectionCard(
              "Contact Details",
              Icons.phone_outlined,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputLabelField(
                          "PHONE", phoneC),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputLabelField("EMAIL", emailC),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroonRed,
                ),
                onPressed:
                isSaving ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
    ),
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await AuthService.logout();

        if (!mounted) return;

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    },
    child: const Text(
      "Logout",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
          ],
        ),
      ),

      bottomNavigationBar:
      const CustomBottomNavBar(activeIndex: 4),
    );
  }
}