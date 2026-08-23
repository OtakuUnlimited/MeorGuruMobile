import 'package:flutter/material.dart';

class EventPackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onBookNow;

  const EventPackageCard({
    Key? key,
    required this.package,
    required this.onBookNow,
  }) : super(key: key);

  String _formatShortDescription(String description) {
    String text = description.trim();

    // Remove "Includes:" from the beginning
    if (text.toLowerCase().startsWith('includes:')) {
      text = text.substring('Includes:'.length).trim();
    }

    // Split by comma
    final items = text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final buffer = StringBuffer();

    // Add Includes heading
    buffer.writeln('Includes:');

    // Add numbered items
    for (int i = 0; i < items.length; i++) {
      buffer.writeln('${i + 1}. ${items[i]}');
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        package['title']?.toString() ??
        package['name']?.toString() ??
        '';

    final String subtitle =
        package['sub_title']?.toString() ??
        package['subtitle']?.toString() ??
        package['english_title']?.toString() ??
        package['slug']?.toString() ??
        '';

    final String image =
        package['image']?.toString() ??
        package['thumbnail']?.toString() ??
        '';

    final String shortDescription =
        package['short_description']?.toString() ?? '';

    final String formattedDescription =
        shortDescription.isNotEmpty
            ? _formatShortDescription(shortDescription)
            : '';

    final String price =
        package['price'] != null
            ? '\$${package['price']}'
            : 'Contact';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEFEFEF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= IMAGE =================

            Container(
              height: 140,
              color: const Color(0xFFF3EFEA),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),

            // ================= CONTENT =================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= TITLE =================

                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB33A0F),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // ================= SUBTITLE =================

                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // ================= DESCRIPTION =================

                    if (formattedDescription.isNotEmpty)
                      Expanded(
                        child: Text(
                          formattedDescription,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF333333),
                            height: 1.35,
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    // ================= PRICE =================

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starts at',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFA6400),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // ================= BOOK BUTTON =================

                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA6400),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}