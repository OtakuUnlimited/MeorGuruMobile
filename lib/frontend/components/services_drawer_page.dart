import 'package:flutter/material.dart';
import '../../constants.dart';
import '../pages/online_puja_screen.dart';
import '../../routes/app_routes.dart';
// import '../pages/astrology_screen.dart';
// import '../pages/auspicious_days_screen.dart';

class ServicesDrawerPage extends StatelessWidget {
  const ServicesDrawerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 12),
      child: Column(
        children: [
          // Dismiss Arrow Button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.orangeMain, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Static Core Services Menu (Kept as requested)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                    children: [
                      _buildDrawerIcon(
                        context,
                        Icons.notifications_none,
                        "Online\nPuja",
                        () {
                          Navigator.pop(context);

                          Navigator.pushNamed(
                            context,
                            '/online-puja',
                          );
                        },
                      ),

                      _buildDrawerIcon(
                        context,
                        Icons.star_outline,
                        "Astrology\nServices",
                        () {
                          Navigator.pop(context);

                          Navigator.pushNamed(
                            context,
                            '/astrology',
                          );
                        },
                      ),

                      _buildDrawerIcon(
                        context,
                        Icons.celebration_outlined,
                        "Event\nManagement",
                        () {
                          Navigator.pop(context);

                           Navigator.pushNamed(
                            context,
                            AppRoutes.eventPackages,
                          );
                        },
                      ),

                      _buildDrawerIcon(
                        context,
                        Icons.calendar_today,
                        "Auspicious\nDays",
                        () {
                          Navigator.pop(context);

                          Navigator.pushNamed(
                            context,
                            AppRoutes.auspiciousCalender,
                          );
                        },
                      ),
                    ],
                  ),
                  
                  // Divider to cleanly separate the Core items from Dynamic Related items
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Builder method kept exclusively for the local static Core Services items
  Widget _buildDrawerIcon(
  BuildContext context,
  IconData icon,
  String label,
  VoidCallback onTap,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.orangeMain,
          size: 28,
        ),

        const SizedBox(height: 6),

        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
}