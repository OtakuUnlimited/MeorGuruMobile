import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class AstrologyDetailScreen extends StatefulWidget {
  final String slug;

  const AstrologyDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<AstrologyDetailScreen> createState() =>
      _AstrologyDetailScreenState();
}

class _AstrologyDetailScreenState
    extends State<AstrologyDetailScreen> {

  final ContentService _contentService = ContentService();

  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();

    _future =
        _contentService.fetchAstrologyDetails(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: const CustomTopNavBar(
        title: "Mero Guru",
        showBack: true,
      ),

      body: FutureBuilder<dynamic>(
  future: _future,
  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return const Center(
        child: Text("Unable to load details"),
      );
    }

    final data = snapshot.data['data'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Center(
            child: Text(
              data['title'] ?? '',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA6400),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                data['image'] ?? '',
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            data['short_description'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _removeHtmlTags(
              data['description'] ?? '',
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              "Price: \$${data['price']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
              ),
              onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.astrologyOrder,
                    arguments: data,
                  );
                },
              child: const Text(
                "BOOK NOW",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
),
    );
  }

  String _removeHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}