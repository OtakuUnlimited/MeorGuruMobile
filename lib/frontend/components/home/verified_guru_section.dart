// components/home/verified_guru_section.dart

import 'package:flutter/material.dart';

import '../../../backend/services/content_services.dart';
import '../../../constants.dart';
import '../../pages/guru_profile_screen.dart';

class VerifiedGuruSection extends StatelessWidget {
  const VerifiedGuruSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ContentService().fetchAllGurus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                "Failed to load gurus",
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text("No gurus found"),
            ),
          );
        }

        final gurus = snapshot.data!;

        final displayCount = gurus.length > 6
            ? 7 // 6 gurus + See More
            : gurus.length;

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              // SEE MORE CARD
              if (gurus.length > 6 && index == 6) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/guru',
                    );
                  },
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.orangeMain.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.orangeMain,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                          color: AppColors.orangeMain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "See More",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.orangeMain,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final guru = gurus[index];

              final String imageUrl = guru['avatar'] ?? '';

              final String fullName = [
                guru['first_name'],
                guru['middle_name'],
                guru['last_name'],
              ]
                  .where(
                    (e) =>
                        e != null &&
                        e.toString().trim().isNotEmpty,
                  )
                  .join(' ');

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuruProfileScreen(
                        slug: guru['slug'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.maroonRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}