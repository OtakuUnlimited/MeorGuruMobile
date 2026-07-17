import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/guru/service_details_card.dart';
import '../components/guru/professional_profile_card.dart';
import '../components/guru/location_details_block.dart';
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
  final ContentService _contentService = ContentService();

  bool _loading = true;
  Map<String, dynamic>? guru;

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  Future<void> _loadGuru() async {
    try {
      final response =
          await _contentService.fetchGuruDetails(widget.slug);

      print(response);

      setState(() {
        guru = Map<String, dynamic>.from(response['data'][0]);
        _loading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (guru == null) {
      return const Scaffold(
        body: Center(
          child: Text("Guru not found"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopNavBar(
        title: "Mero Guru",
        style: NavBarStyle.BrandedLight,
        showBack: true,
        showProfile: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          guru!['avatar'] ??
                              'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 4,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Text(
                "${guru!['first_name']} "
                "${guru!['middle_name'] ?? ''} "
                "${guru!['last_name']}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                '"Preserving Tradition, Inspiring Faith"',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "ABOUT ME",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              guru!['about_us'] ?? "No description available.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            ServiceDetailsCard(
              guru: guru!,
            ),

            const SizedBox(height: 20),

            LocationDetailsBlock(
              guru: guru!,
            ),

            const SizedBox(height: 20),

            ProfessionalProfileCard(
              guru: guru!,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFB34200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Get in Touch",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.help_outline,
                        color: Colors.white.withOpacity(.8),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildContactRow(
                    Icons.phone_outlined,
                    "PHONE NUMBER",
                    "+${guru!['country_code']} ${guru!['phone']}",
                  ),

                  const SizedBox(height: 12),

                  _buildContactRow(
                    Icons.mail_outline,
                    "EMAIL ADDRESS",
                    guru!['email'] ?? "-",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 4,
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(.2),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}