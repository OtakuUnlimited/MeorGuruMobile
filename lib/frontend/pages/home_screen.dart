// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

import '../components/home/hero_banner.dart';
import '../components/home/section_header.dart';
import '../components/category_grid_view.dart';
import '../components/home/online_puja_section.dart';
import '../components/home/verified_guru_section.dart';
import '../components/home/blog_section.dart';
import '../components/home/about_section.dart';
import '../components/home/top_decoration_section.dart';
import '../components/home/popular_venues_section.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomTopNavBar(
        title: "Mero Guru",
        style: NavBarStyle.BrandedLight,
        showMenu: true,
        showProfile: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [

            /// HERO BANNER
            HeroBanner(),

            SizedBox(height: 20),

            /// CATEGORIES
            SectionHeader(
              title: "Related Services",
            ),

            CategoryGridView(),

            SizedBox(height: 20),

            /// ONLINE PUJA
            SectionHeader(
              title: "Online Puja Services",
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  '/decoration-services',
                );
              },
            ),

            OnlinePujaSection(),

            SizedBox(height: 20),

            /// VERIFIED GURUS
            SectionHeader(
              title: "Our Verified Gurus",
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  '/guru',
                );
              },
            ),

            VerifiedGuruSection(),

            SizedBox(height: 20),

            SectionHeader(
              title: "Top Decoration Service Providers",
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  '/decoration-services',
                );
              },
            ),

            TopDecorationSection(),

            SizedBox(height: 25),

            SectionHeader(
              title: "Popular Venues",
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  '/venues',
                );
              },
            ),

            PopularVenuesSection(),

            SizedBox(height: 20),

            /// BLOGS
            SectionHeader(
              title: "MeroGuru Blog",
            ),

            BlogSection(),

            SizedBox(height: 30),

            /// ABOUT SECTION
            AboutSection(),

            SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 0,
      ),
    );
  }
}