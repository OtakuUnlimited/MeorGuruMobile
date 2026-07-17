import 'package:flutter/material.dart';

class ProfessionalProfileCard extends StatelessWidget {
  final Map<String, dynamic> guru;

  const ProfessionalProfileCard({
    Key? key,
    required this.guru,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert spoken_language to a List<String>
    List<String> languages = [];

    if (guru['spoken_language'] is List) {
      languages = List<String>.from(
        (guru['spoken_language'] as List).map((e) => e.toString()),
      );
    } else if (guru['spoken_language'] != null &&
        guru['spoken_language'].toString().trim().isNotEmpty) {
      languages = guru['spoken_language']
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5).withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFEFEA),
                child: Icon(
                  Icons.school_outlined,
                  color: Colors.amber.shade800,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Professional Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildProfileSection(
            'HIGHEST QUALIFICATION',
            (guru['qualification'] == null ||
                    guru['qualification'].toString().isEmpty)
                ? 'Not Available'
                : guru['qualification'].toString(),
          ),

          const SizedBox(height: 16),

          _buildProfileSection(
            'ASSOCIATED TEMPLE',
            (guru['associated_temple'] == null ||
                    guru['associated_temple'].toString().isEmpty)
                ? 'Not Available'
                : guru['associated_temple'].toString(),
          ),

          const SizedBox(height: 16),

          Text(
            'SPOKEN LANGUAGES',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          if (languages.isEmpty)
            const Text(
              'Not Available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: languages
                  .map(
                    (lang) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lang.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    String heading,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}