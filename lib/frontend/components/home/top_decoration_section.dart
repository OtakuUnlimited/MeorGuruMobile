import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../backend/services/content_services.dart';

class TopDecorationSection extends StatelessWidget {
  const TopDecorationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ContentService().fetchTopDecorations(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox(
            child: Center(child: Text("No decorations found")),
          );
        }

        final services = snapshot.data!.take(5).toList();

        return Column(
          children: services.map((service) {

            // 🔥 SAFE FIELD ACCESS (prevents silent UI failure)
            final image = (service['image'] ?? '').toString();
            final title = (service['title'] ?? service['name'] ?? 'No Title').toString();
            final location = (service['location'] ?? service['city'] ?? 'Australia').toString();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  )
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image.isNotEmpty ? image : "https://via.placeholder.com/100",

                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,

                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: 100,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGray),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}