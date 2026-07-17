// components/home/online_puja_section.dart

import 'package:flutter/material.dart';
import '../../../backend/services/content_services.dart';
import '../../../routes/app_routes.dart';

class OnlinePujaSection extends StatelessWidget {
  const OnlinePujaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ContentService().fetchOnlinePujas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final pujas = snapshot.data!;

        // Show max 5 pujas + 1 See More card
        final displayCount = pujas.length > 5 ? 6 : pujas.length;

        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayCount,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {

              // Last card = See More
              if (pujas.length > 5 && index == 5) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.orange,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.onlinePuja,
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "See More",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final puja = pujas[index];
              return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.onlinePujaDetail,
                  arguments: puja['slug'],
                );
              },
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          puja['image'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        puja['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              )
              );
            },
          ),
        );
      },
    );
  }
}