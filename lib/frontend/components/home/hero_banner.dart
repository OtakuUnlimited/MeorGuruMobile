// components/home/hero_banner.dart

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../routes/app_routes.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/images/main-banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Find The Best Guru",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Anywhere in Australia",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.orangeMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () 
            {
              Navigator.pushNamed(
                  context,
                  '/guru',
                );
            },
            icon: const Icon(Icons.search),
            label: const Text("Find a Guru"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMain,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )
        ],
      ),
    );
  }
}