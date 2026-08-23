import 'package:flutter/material.dart';
import '../../constants.dart';
import 'category_grid_view.dart';
import '../../routes/app_routes.dart';

class HamburgerOverlay extends StatelessWidget {
  const HamburgerOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// Close overlay when tapping outside
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          /// Menu Sheet
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: kToolbarHeight),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mero Guru Services",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: AppColors.borderGray,
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          /// QUICK LINKS
                          const Text(
                            "Quick Links",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          GridView.count(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            children: [
                              _buildQuickLinkItem(
                                context,
                                Icons.home,
                                "Home",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/',
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.star_outline,
                                "Astrology\nServices",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.astrology,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.calendar_today,
                                "Auspicious\nDays",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/auspicious-days',
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.book_outlined,
                                "MeroGuru\nBlogs",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.blogs,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.notifications_none,
                                "Online\nPuja",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.onlinePuja,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.shopping_bag_outlined,
                                "Shop",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.shop,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.wb_sunny_outlined,
                                "Patro",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.patro,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.person_outline,
                                "Find Gurus",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.guru,
                                  );
                                },
                              ),

                              _buildQuickLinkItem(
                                context,
                                Icons.account_circle_outlined,
                                "Profile",
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.profile,
                                  );
                                },
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child: Divider(
                              color: AppColors.borderGray,
                              thickness: 1,
                            ),
                          ),

                          /// RELATED SERVICES
                          const Text(
                            "Related Services",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          CategoryGridView(
                            crossAxisCount: 3,
                            childAspectRatio: 0.78,
                            isCompact: true,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            onCategoryTap: (category) {
                              Navigator.pop(context);

                              Navigator.pushNamed(
                                context,
                                '/services-by-category',
                                arguments: {
                                  'slug': category['slug'],
                                  'title': category['title'],
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.orangeMain,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                height: 1.2,
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