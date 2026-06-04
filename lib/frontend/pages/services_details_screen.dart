import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/service_header_widget.dart';
import '../components/location_details_widget.dart';
import '../components/service_contact_widget.dart';

class ServicesDetailsScreen extends StatefulWidget {
  final String slug;

  const ServicesDetailsScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  State<ServicesDetailsScreen> createState() =>
      _ServicesDetailsScreenState();
}

class _ServicesDetailsScreenState extends State<ServicesDetailsScreen> {
  final ContentService _contentService = ContentService();

  Map<String, dynamic>? service;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  Future<void> _loadService() async {
    try {
      final response =
          await _contentService.serviceDetails(widget.slug);

      if (mounted) {
        setState(() {
          service = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Service Details Error: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Convert any value into list of chips
  List<String> _normalizeValue(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [value.toString()];
  }

  /// Build dynamic specialties map (EXCLUDING used fields)
  List<MapEntry<String, List<String>>> _buildSpecialties(Map data) {
  final excludeKeys = {
    "id",
    "category_id",
    "title",
    "nepali_title",
    "sub_title",
    "type",
    "price",
    "slug",
    "image",
    "short_description",
    "description",
    "country",
    "state",
    "suburb",
    "address",
    "phone",
    "email",
    "seo_title",
    "seo_description",
    "status",
  };

  final List<MapEntry<String, List<String>>> result = [];

  data.forEach((key, value) {
    if (excludeKeys.contains(key)) return;

    // 🔥 FIX: handle ALL types properly
    List<String> chips = [];

    if (value is List) {
      chips = value.map((e) => e.toString()).toList();
    } 
    else if (value != null) {
      final str = value.toString().trim();

      // ❗ IMPORTANT FIX: show even "empty-looking" values if not null
      if (str.isNotEmpty) {
        chips = str.contains(',')
            ? str.split(',').map((e) => e.trim()).toList()
            : [str];
      } else {
        chips = ["N/A"]; // fallback so UI is NOT empty
      }
    }

    // 🔥 Always show key if it's not excluded
    result.add(
      MapEntry(
        key.toString().toUpperCase().replaceAll('_', ' '),
        chips,
      ),
    );
  });

  return result;
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = service ?? {};

    final specialties = _buildSpecialties(data);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(activeIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            ServiceHeaderWidget(
              image: data['image'] ?? '',
              title: data['title'] ?? '',
              subtitle: data['sub_title'] ?? '',
            ),

            const SizedBox(height: 24),

            /// LOCATION
            LocationDetailsWidget(
              country: data['country'] ?? '-',
              state: data['state'] ?? '-',
              suburb: data['suburb'] ?? '-',
              address: data['address'] ?? '-',
            ),

            const SizedBox(height: 24),

            /// SERVICES & SPECIALTIES (DYNAMIC)
            if (specialties.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: const Text(
                  'Services & Specialties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: specialties.map((entry) {
                  return _buildChipGroup(entry.key, entry.value);
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            /// ABOUT
            const Text(
              'About Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Html(
                data: data['description'] ?? '',
              ),
            ),

            const SizedBox(height: 24),

            /// CONTACT
            ServiceContactWidget(
              phone: data['phone'] ?? '-',
              email: data['email'] ?? '-',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// CHIP UI (UNCHANGED DESIGN)
  Widget _buildChipGroup(String heading, List<String> chips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFAD4000),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chips.map((chipText) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5A27),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    chipText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}