import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/service_vendor_card.dart';

class ServicesPageScreen extends StatefulWidget {
final String slug;
const ServicesPageScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<ServicesPageScreen> createState() => _ServicesPageScreenState();
}

class _ServicesPageScreenState extends State<ServicesPageScreen> {
  final ContentService _contentService = ContentService();

  List<dynamic> categories = [];
  List<dynamic> services = [];

  String? selectedCategorySlug;
  String selectedCategoryTitle = '';

  bool isLoadingCategories = true;
  bool isLoadingServices = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _contentService.getCachedCategories();

      if (data.isNotEmpty) {
        setState(() {
          categories = data;
          selectedCategorySlug = widget.slug.isNotEmpty
            ? widget.slug
            : data.first['slug'];

        selectedCategoryTitle = data.firstWhere(
          (c) => c['slug'] == selectedCategorySlug,
          orElse: () => data.first,
        )['title'] ?? '';
      });

        await _loadServices(selectedCategorySlug!);
      }
    } catch (e) {
      debugPrint('Category Error: $e');
    }

    if (mounted) {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadServices(String slug) async {
    setState(() {
      isLoadingServices = true;
    });

    try {
      final response = await _contentService.servicesDetails(slug);

      setState(() {
        services = response['data']['services'] ?? [];
      });
    } catch (e) {
      debugPrint('Services Error: $e');
      setState(() {
      services = [];
    });
    }

    if (mounted) {
      setState(() {
        isLoadingServices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showMenu: true,
        showProfile: true,
        style: NavBarStyle.BrandedLight,
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isLoadingCategories
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: categories.map((cat) {
                          final bool isCurrent =
                              selectedCategorySlug == cat['slug'];

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedCategorySlug = cat['slug'];
                                  selectedCategoryTitle =
                                      cat['title'] ?? '';
                                });

                                await _loadServices(cat['slug']);
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: isCurrent
                                        ? const Color(0xFFB33A0F)
                                        : const Color(0xFFF1F1F1),
                                    child: ClipOval(
                                      child: Image.network(
                                        cat['image'] ?? '',
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Icon(
                                          Icons.category,
                                          color: isCurrent
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 85,
                                    child: Text(
                                      cat['title'] ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrent
                                            ? const Color(0xFFB33A0F)
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCategoryTitle.isEmpty
                              ? 'Services'
                              : selectedCategoryTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Found ${services.length} professional providers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {},
                    color: Colors.black87,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Services List
            if (isLoadingServices)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (services.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    'No services found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ServiceVendorCard(
                    service: services[index],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}