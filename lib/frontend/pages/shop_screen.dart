import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/shop_search_banner.dart';
import '../components/shop/shop_category_scroller.dart';
import '../components/shop/popular_item_carousel.dart';
import '../components/shop/shop_widgets.dart'; // Contains ProductCard structural styling
import '../../backend/services/shop_service.dart';
import '../../routes/app_routes.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();

  bool _loading = true;

  String _activeCategory = 'All';

 List<Map<String, dynamic>> _categories = [];
List<Map<String, dynamic>> _popularItems = [];
List<Map<String, dynamic>> _featuredItems = [];

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
  print("Loading shop...");

  try {
    _categories = await _shopService.getCategories();
    print("Categories Loaded: ${_categories.length}");

    _popularItems = await _shopService.getPopularProducts();
    print("Popular Loaded: ${_popularItems.length}");

    _featuredItems = await _shopService.getFeaturedProducts();
    print("Featured Loaded: ${_featuredItems.length}");

    print("First Featured:");
    if (_featuredItems.isNotEmpty) {
      print(_featuredItems.first);
    }

    setState(() {
      _loading = false;
    });
  } catch (e, stack) {
    print("SHOP ERROR:");
    print(e);
    print(stack);

    setState(() {
      _loading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Integrated custom shared top bar with your actions config context
      appBar: CustomTopNavBar(
        title: 'Mero Guru',
        style: NavBarStyle.BrandedLight,
        showMenu: true,
        showCart: true,
      ),
      body: _loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            ShopSearchBanner(
              onSearchChanged: (query) {},
              onFilterTap: () {},
            ),

            const SizedBox(height: 16),

            ShopCategoryScroller(
              categories: [
                'All',
                ..._categories.map((e) => e['name'].toString()),
              ],
              selectedCategory: _activeCategory,
              onCategorySelected: (category) async {
                print("Category Selected: $category");
                setState(() {
                  _activeCategory = category;
                });

                if (category == 'All') {
                  final items =
                      await _shopService.getFeaturedProducts();

                  setState(() {
                    _featuredItems = items;
                  });
                } else {
                  final slug = _categories.firstWhere(
                    (e) => e['name'] == category,
                  )['slug'];
                  print("Slug: $slug");

                  final items =
                      await _shopService.getProducts(category: slug);
                      print(items);

                  setState(() {
                    _featuredItems = items;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Popular Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            PopularItemsCarousel(
              items: _popularItems,
              onItemTap: (item) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.itemDetail,
                  arguments: item['slug'],
                );
              },
            ),

            const SizedBox(height: 24),

            Text(
              _activeCategory == 'All'
                  ? 'Featured Items'
                  : _activeCategory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _featuredItems.length,
              itemBuilder: (context, index) {
                final product = _featuredItems[index];

                final image = (product['images'] as List).isNotEmpty
                    ? product['images'][0]
                    : '';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.itemDetail,
                      arguments: product['slug'],
                    );
                  },
                  child: ProductCard(
                    title: product['name'],
                    priceString:
                        '\$${product['discounted_price'] ?? product['price']}',
                    imagePathUrl: image,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 2,
      ),
    );
  }
}