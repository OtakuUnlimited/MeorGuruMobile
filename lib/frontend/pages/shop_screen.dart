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
  bool _productsLoading = false;

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
  try {
    final results = await Future.wait([
      _shopService.getCategories(),
      _shopService.getPopularProducts(),
      _shopService.getProducts(),
    ]);

    if (!mounted) return;

    setState(() {
      _categories =
          results[0] as List<Map<String, dynamic>>;

      _popularItems =
          results[1] as List<Map<String, dynamic>>;

      _featuredItems =
          results[2] as List<Map<String, dynamic>>;

      _activeCategory = 'All';
      _loading = false;
    });
  } catch (error, stackTrace) {
    debugPrint('SHOP ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }
}



Future<void> _searchProducts(String query) async {
  final search = query.trim();

  setState(() {
    _productsLoading = true;
  });

  try {
    String? categorySlug;

    if (_activeCategory != 'All') {
      final selectedCategory = _categories.firstWhere(
        (item) =>
            item['name']?.toString() ==
            _activeCategory,
      );

      categorySlug =
          selectedCategory['slug']?.toString();
    }

    final products = await _shopService.getProducts(
      search: search,
      category: categorySlug,
    );

    if (!mounted) return;

    setState(() {
      _featuredItems = products;
      _loading = false;
    });
  } catch (error, stackTrace) {
    debugPrint('SEARCH ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

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
              onSearch: _searchProducts,
            ),

            const SizedBox(height: 16),

            ShopCategoryScroller(
              categories: [
                'All',
                ..._categories.map((e) => e['name'].toString()),
              ],
              selectedCategory: _activeCategory,
             onCategorySelected: (category) async {
              if (category == _activeCategory) return;

              setState(() {
                _activeCategory = category;
                _productsLoading = true;
              });

              try {
                late List<Map<String, dynamic>> items;

                if (category == 'All') {
                  items = await _shopService.getProducts();
                } else {
                  final selectedCategory = _categories.firstWhere(
                    (item) =>
                        item['name']?.toString() == category,
                  );

                  final slug =
                      selectedCategory['slug']?.toString() ?? '';

                  items = await _shopService.getProducts(
                    category: slug,
                  );
                }

                if (!mounted) return;

                setState(() {
                  _featuredItems = items;
                  _productsLoading = false;
                });
              } catch (error, stackTrace) {
                debugPrint(
                  'CATEGORY PRODUCTS ERROR: $error',
                );
                debugPrintStack(stackTrace: stackTrace);

                if (!mounted) return;

                setState(() {
                  _productsLoading = false;
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
                  ? 'All Products'
                  : _activeCategory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),
    _productsLoading
    ? const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
    : _featuredItems.isEmpty
        ? const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'No products found',
              ),
            ),
          )
        : GridView.builder(
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

                  final originalPrice = double.tryParse(
                    product['price']?.toString() ?? '0',
                  ) ??
                  0;

                  final discountedPrice = double.tryParse(
                    product['discounted_price']?.toString() ??
                        '',
                  );

                  final hasDiscount =
                      discountedPrice != null &&
                      discountedPrice < originalPrice;

                  final rawStock = product['in_stock'];

                  final inStock = rawStock == true ||
                      rawStock == 1 ||
                      rawStock?.toString() == '1';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.itemDetail,
                        arguments: product['slug'],
                      );
                    },
                    child: ProductCard(
                      title:
                          product['name']?.toString() ?? '',
                      priceString:
                          '\$${originalPrice.toStringAsFixed(2)} AUD',
                      discountedPriceString: hasDiscount
                          ? '\$${discountedPrice.toStringAsFixed(2)} AUD'
                          : null,
                      imagePathUrl: image.toString(),
                      inStock: inStock,
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