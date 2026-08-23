import 'package:flutter/material.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class EventPackagesDetailScreen extends StatefulWidget {
  final String slug;

  const EventPackagesDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<EventPackagesDetailScreen> createState() =>
      _EventPackagesDetailScreenState();
}

class _EventPackagesDetailScreenState
    extends State<EventPackagesDetailScreen> {
  final ContentService _contentService = ContentService();

  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();

    _future = _contentService.fetchEventDetails(widget.slug);
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
                // ============================================================
                // TITLE
                // ============================================================

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

                // ============================================================
                // IMAGE
                // ============================================================

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

                // ============================================================
                // SHORT DESCRIPTION
                // ============================================================

                Text(
                  _formatShortDescription(
                    data['short_description'] ?? '',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================================
                // DESCRIPTION TITLE
                // ============================================================

                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ============================================================
                // DESCRIPTION
                // ============================================================

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

                // ============================================================
                // PRICE
                // ============================================================

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

                // ============================================================
                // BOOK NOW BUTTON
                // ============================================================

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
                        AppRoutes.eventPackagesOrder,
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

  // ============================================================
  // FORMAT SHORT DESCRIPTION
  // ============================================================

  String _formatShortDescription(String description) {
    String text = description.trim();

    if (text.isEmpty) {
      return '';
    }

    // Remove "Includes:" from the beginning
    if (text.toLowerCase().startsWith('includes:')) {
      text = text.substring('Includes:'.length).trim();
    }

    // Split the description by commas
    final items = text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final buffer = StringBuffer();

    // Add "Includes:" on its own line
    buffer.writeln('Includes:');

    // Add numbering
    for (int i = 0; i < items.length; i++) {
      buffer.writeln('${i + 1}. ${items[i]}');
    }

    return buffer.toString().trim();
  }

  // ============================================================
  // REMOVE HTML TAGS
  // ============================================================

  String _removeHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}