import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/shop_search_banner.dart';
import '../components/shop/shop_category_scroller.dart';
import '../components/shop/popular_item_carousel.dart';
import '../components/shop/shop_widgets.dart'; // Contains ProductCard structural styling

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _activeCategory = 'All';
  
  final List<String> _categories = ['All', 'Ghanti', 'Puja Samagri', 'Tika', 'Karuwa'];

  // Realistic mock data maps representing images/prices from your layout mockup
  final List<Map<String, dynamic>> _mockProducts = [
    {'title': 'Sukunda Brass Vase\nlorem lorem', 'price': '9999AUD', 'image': 'https://picsum.photos/id/1080/300/300', 'isBell': false},
    {'title': 'Pooja Bell (Ghanti)\nlorem lorem', 'price': '450AUD', 'image': 'https://picsum.photos/id/1025/300/300', 'isBell': true},
    {'title': 'Asthadhatu Karuwa\nlorem lorem', 'price': '1200AUD', 'image': 'https://picsum.photos/id/1080/300/300', 'isBell': false},
    {'title': 'Traditional Tika Set\nlorem lorem', 'price': '150AUD', 'image': 'https://picsum.photos/id/1025/300/300', 'isBell': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Integrated custom shared top bar with your actions config context
      appBar: CustomTopNavBar(
        title: 'Mero Guru',
        style: NavBarStyle.BrandedLight,
        showMenu: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: AppColors.orangeMain, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            
            // 1. Search Box Component File
            ShopSearchBanner(
              onSearchChanged: (query) {},
              onFilterTap: () {},
            ),
            const SizedBox(height: 16),
            
            // 2. Category Pill Tags Row Component File
            ShopCategoryScroller(
              categories: _categories,
              selectedCategory: _activeCategory,
              onCategorySelected: (category) {
                setState(() => _activeCategory = category);
              },
            ),
            const SizedBox(height: 24),
            
            const Text('Popular Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            
            // 3. Carousel Horizontal Items Strip Component File
            PopularItemsCarousel(
              items: _mockProducts,
              onItemTap: (selectedItem) {},
            ),
            const SizedBox(height: 24),
            
            const Text('Featured Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            
            // 4. Multi-column Infinite Featured Grid view layout mapping individual product cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final product = _mockProducts[index % _mockProducts.length];
                return ProductCard(
                  title: product['title'],
                  priceString: product['price'],
                  imagePathUrl: product['image'],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Uses your rewritten universal navigation component (index 2 for Shop highlights)
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}