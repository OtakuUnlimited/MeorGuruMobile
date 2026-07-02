import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/service_card.dart';
import '../components/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({Key? key}) : super(key: key);

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final ContentService _contentService = ContentService();

  bool isLoading = true;
  List<dynamic> astrologyServices = [];

  @override
  void initState() {
    super.initState();
    loadAstrologyServices();
  }

  Future<void> loadAstrologyServices() async {
    try {
      final data = await _contentService.fetchAstrologyServices();

      setState(() {
        astrologyServices = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Astrology Services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFA6400),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Experience the divine from the comfort of your home. Our Astrology services bring sacred rituals, expert priests and spiritual blessings directly to you – wherever you are.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: astrologyServices.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final service = astrologyServices[index];

                      return ServiceCard(
                        devanagariTitle:
                            service['nepali_title'] ?? '',
                        englishTitle:
                            service['title'] ?? '',
                        price:
                            "\$${service['price']}",
                        imageUrl:
                            service['image'] ?? '',
                        onBookNow: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.astrologyDetail,
                            arguments: service['slug'],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 3,
      ),
    );
  }
}