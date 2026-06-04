import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';

class GuruProfileScreen extends StatefulWidget {
  final String slug;

  const GuruProfileScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  State<GuruProfileScreen> createState() => _GuruProfileScreenState();
}

class _GuruProfileScreenState extends State<GuruProfileScreen> {
  late Future<dynamic> guruFuture;

  @override
  void initState() {
    super.initState();

    print("===== GURU PROFILE OPENED =====");
    print("Slug: ${widget.slug}");

    guruFuture = ContentService().fetchGuruDetails(widget.slug);
  }

  Map<String, dynamic> _parseGuru(dynamic response) {
    print("===== RAW RESPONSE =====");
    print(response);

    try {
      if (response is Map && response['data'] != null) {
        if (response['data'] is List) {
          return Map<String, dynamic>.from(response['data'][0]);
        }
        return Map<String, dynamic>.from(response['data']);
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print("PARSE ERROR: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        style: NavBarStyle.BrandedLight,
        showMenu: true,
      ),
      backgroundColor: AppColors.bg,

      body: FutureBuilder(
        future: guruFuture,
        builder: (context, snapshot) {

          print("===== FUTURE STATE =====");
          print(snapshot.connectionState);
          print(snapshot.hasData);
          print(snapshot.hasError);
          print(snapshot.error);
          print(snapshot.data);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Guru Found"));
          }

          final guru = _parseGuru(snapshot.data);

          final avatar = guru['avatar'] ?? '';

          final fullName = [
            guru['first_name'] ?? '',
            guru['middle_name'] ?? '',
            guru['last_name'] ?? '',
          ].where((e) => e.toString().trim().isNotEmpty).join(' ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ================= IMAGE (UNCHANGED UI) =================
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.orangeMain.withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage:
                            avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= NAME (NOW FROM API) =================
                Text(
                  fullName.isEmpty ? "Unknown Guru" : fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 4),

                // ================= TAGLINE (SAFE) =================
                Text(
                  guru['about_us'] ?? guru['about_me'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.orangeMain,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                // ================= ABOUT ME (STATIC UI KEPT) =================
                _section(
                  "ABOUT ME",
                  guru['about_us'] ?? guru['about_me'] ??
                      "No description available.",
                ),

                const SizedBox(height: 16),

                // ================= SERVICE DETAILS (STATIC UI + DATA OPTIONAL) =================
                _section(
                  "SERVICE DETAILS",
                  "Experience: ${guru['experience'] ?? 'N/A'}\n"
                      "Qualification: ${guru['qualification'] ?? 'N/A'}\n"
                      "Availability: ${guru['availability'] ?? 'N/A'}",
                ),

                const SizedBox(height: 16),

                // ================= LOCATION (YOUR UI LOGIC KEPT) =================
                _section(
                  "LOCATION DETAILS",
                  "Country: ${guru['country'] ?? 'N/A'}\n"
                      "State: ${guru['state'] ?? 'N/A'}\n"
                      "City: ${guru['suburb'] ?? 'N/A'}\n"
                      "Post Code: ${guru['postal_code'] ?? 'N/A'}",
                ),

                const SizedBox(height: 16),

                // ================= CONTACT =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brownAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Get in Touch",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("Phone: ${guru['phone'] ?? '-'}",
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 6),
                      Text("Email: ${guru['email'] ?? '-'}",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 4),
    );
  }

  Widget _section(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}