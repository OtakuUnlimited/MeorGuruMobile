import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/service_card.dart';
import '../components/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class OnlinePujaScreen extends StatefulWidget {
  const OnlinePujaScreen({Key? key}) : super(key: key);

  @override
  State<OnlinePujaScreen> createState() => _OnlinePujaScreenState();
}

class _OnlinePujaScreenState extends State<OnlinePujaScreen> {
  final ContentService _contentService = ContentService();

  bool isLoading = true;
  List<dynamic> pujaServices = [];

  @override
  void initState() {
    super.initState();
    loadPujas();
  }

  Future<void> loadPujas() async {
    try {
      final data = await _contentService.fetchOnlinePujas();

      setState(() {
        pujaServices = data;
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
                    'List of Online Puja\nServices',
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
                      'Experience the divine from the comfort of your home. Our online Puja services bring sacred rituals, expert priests and spiritual blessings directly to you - wherever you are.',
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
                    itemCount: pujaServices.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final service = pujaServices[index];

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
                            AppRoutes.onlinePujaDetail,
                            arguments: service['slug'],
                          );// navigate later
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