import 'package:flutter/material.dart';
import '../components/event_package_card.dart';
import '../../backend/services/content_services.dart';
import '../../routes/app_routes.dart';
import '../components/top_nav_bar.dart';

class EventPackagesScreen extends StatefulWidget {
  const EventPackagesScreen({Key? key}) : super(key: key);

  @override
  State<EventPackagesScreen> createState() =>
      _EventPackagesScreenState();
}

class _EventPackagesScreenState
    extends State<EventPackagesScreen> {
  final ContentService _contentService = ContentService();

  bool _loading = true;

  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages =
          await _contentService.fetchEvents();

      print("===== EVENT PACKAGES =====");
      print(packages);

      setState(() {
        _packages = packages;
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Column(
                children: [
                  const Text(
                    'List of Event\nPackages',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFA6400),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'Discover our diamond, platinum, and gold tiers, meticulously curated to transform your milestones into legendary celebrations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _packages.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(
                            top: 40,
                          ),
                          child: Text(
                            "No event packages found.",
                          ),
                        )
                      : GridView.builder(
                          
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              _packages.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing:
                                14,
                            mainAxisSpacing:
                                16,
                            childAspectRatio:
                                0.52,
                          ),
                          itemBuilder:
                              (context, index) {
                                final services = _packages[index];
                            return EventPackageCard(
                              package:
                                  _packages[index],
                              onBookNow: () {
                               Navigator.pushNamed(
                                context,
                                AppRoutes.eventPackagesDetail,
                                arguments: services['slug'],
                              );
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}