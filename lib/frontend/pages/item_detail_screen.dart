import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/cart_notifier.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/shop_widgets.dart';
import '../components/shop/item_image_gallery.dart';
import '../../backend/services/shop_service.dart';
import '../../routes/app_routes.dart';

class ItemDetailScreen extends StatefulWidget {
  final String slug;

  const ItemDetailScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() =>
      _ItemDetailScreenState();
}

class _ItemDetailScreenState
    extends State<ItemDetailScreen> {
  int _itemQuantity = 1;

  final ShopService _shopService = ShopService();

  bool _loading = true;
  bool _addingToCart = false;

  Map<String, dynamic>? _product;

  List<Map<String, dynamic>> _relatedProducts = [];

  List<Map<String, dynamic>> _featuredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ============================================================
  // LOAD PRODUCT
  // ============================================================

  Future<void> _loadProduct() async {
    try {
      final product =
          await _shopService.getProductDetail(
        widget.slug,
      );

      final category =
          product['category'];

      final categorySlug =
          category != null
              ? category['slug']
              : null;

      List<Map<String, dynamic>> related = [];

      if (categorySlug != null) {
        related =
            await _shopService.getProducts(
          category: categorySlug,
        );

        related.removeWhere(
          (e) => e['slug'] == widget.slug,
        );
      }

      final featured =
          await _shopService
              .getFeaturedProducts();

      featured.removeWhere(
        (e) => e['slug'] == widget.slug,
      );

      if (!mounted) return;

      setState(() {
        _product = product;

        _relatedProducts = related
            .where(
              (item) =>
                  item['category'] != null,
            )
            .toList();

        _featuredProducts = featured;

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'PRODUCT LOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<bool> _addToCart() async {
    if (_product == null) {
      return false;
    }

    final rawId = _product!['id'];

    final itemId = int.tryParse(
      rawId.toString(),
    );

    if (itemId == null) {
      debugPrint(
        'ADD TO CART ERROR: Invalid item ID',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Invalid product ID'),
          ),
        );
      }

      return false;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      // --------------------------------------------------------
      // CHECK LOGIN STATUS
      // --------------------------------------------------------

      final isLoggedIn =
          await AuthService.isLoggedIn();

      // --------------------------------------------------------
      // PRODUCT DATA FOR GUEST CACHE
      // --------------------------------------------------------

      final productData =
          Map<String, dynamic>.from(
        _product!,
      );

      // --------------------------------------------------------
      // ADD THROUGH CART NOTIFIER
      //
      // Guest:
      //   Saves item to SharedPreferences cache.
      //
      // Logged in:
      //   Sends item to backend cart.
      // --------------------------------------------------------

      final success =
          await cartNotifier.addToCart(
        itemId: itemId,
        product: productData,
        quantity: _itemQuantity,
      );

      if (!mounted) {
        return success;
      }

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Added to cart'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              cartNotifier.error ??
                  'Could not add item to cart',
            ),
          ),
        );
      }

      return success;
    } catch (e) {
      debugPrint(
        'ADD TO CART ERROR: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text('Could not add to cart: $e'),
          ),
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: const CustomTopNavBar(
        title: 'Item Detail',
        style:
            NavBarStyle.BrandedLight,
        showBack: true,
        showCart: true,
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _product == null
              ? const Center(
                  child:
                      Text("Product not found"),
                )
              : Column(
                  children: [
                    Expanded(
                      child:
                          SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            // ==================================================
                            // IMAGE GALLERY
                            // ==================================================

                            ItemImageGallery(
                              images:
                                  List<String>.from(
                                _product![
                                    'images'],
                              ),
                            ),

                            // ==================================================
                            // PRODUCT DETAILS
                            // ==================================================

                            Padding(
                              padding:
                                  const EdgeInsets
                                      .all(20.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    _product![
                                        'name'],
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          32,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          AppColors
                                              .textDark,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    '\$${_product!['discounted_price'] ?? _product!['price']}',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          24,
                                      color:
                                          AppColors
                                              .orangeMain,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // ==================================================
                                  // QUANTITY
                                  // ==================================================

                                  InlineQtyCounter(
                                    currentCount:
                                        _itemQuantity,
                                    onAdd:
                                        () {
                                      setState(() {
                                        _itemQuantity++;
                                      });
                                    },
                                    onRemove:
                                        () {
                                      setState(() {
                                        if (_itemQuantity >
                                            1) {
                                          _itemQuantity--;
                                        }
                                      });
                                    },
                                    compactStyle:
                                        false,
                                  ),

                                  const SizedBox(
                                    height: 24,
                                  ),

                                  // ==================================================
                                  // CATEGORY
                                  // ==================================================

                                  Text(
                                    _product![
                                            'category']
                                        ['name'],
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize:
                                          14,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  // ==================================================
                                  // DESCRIPTION
                                  // ==================================================

                                  Text(
                                    _product![
                                            'description']
                                        .toString()
                                        .replaceAll(
                                          RegExp(
                                            r'<[^>]*>',
                                          ),
                                          '',
                                        ),
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          15,
                                      color: Colors
                                          .black87,
                                      height: 1.4,
                                    ),
                                  ),

                                  const Divider(
                                    height: 40,
                                    thickness: 1,
                                  ),

                                  const Text(
                                    'Related Items',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          AppColors
                                              .textDark,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  // ==================================================
                                  // RELATED PRODUCTS
                                  // ==================================================

                                  SizedBox(
                                    height: 220,
                                    child:
                                        ListView
                                            .builder(
                                      scrollDirection:
                                          Axis.horizontal,
                                      itemCount:
                                          _relatedProducts
                                              .length,
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        final product =
                                            _relatedProducts[
                                                index];

                                        final images =
                                            product[
                                                'images'];

                                        final image =
                                            images
                                                        is List &&
                                                    images
                                                        .isNotEmpty
                                                ? images[
                                                        0]
                                                    .toString()
                                                : '';

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator
                                                .pushReplacementNamed(
                                              context,
                                              AppRoutes
                                                  .itemDetail,
                                              arguments:
                                                  product[
                                                      'slug'],
                                            );
                                          },
                                          child:
                                              ProductCard(
                                            width:
                                                140,
                                            title:
                                                product[
                                                    'name'],
                                            priceString:
                                                '\$${product['discounted_price'] ?? product['price']}',
                                            imagePathUrl:
                                                image,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 30,
                                  ),

                                  // ==================================================
                                  // FEATURED
                                  // ==================================================

                                  const Text(
                                    'Featured Products',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          AppColors
                                              .textDark,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  GridView.builder(
                                    shrinkWrap:
                                        true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2,
                                      childAspectRatio:
                                          0.74,
                                      crossAxisSpacing:
                                          12,
                                      mainAxisSpacing:
                                          12,
                                    ),
                                    itemCount:
                                        _featuredProducts
                                            .length,
                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      final product =
                                          _featuredProducts[
                                              index];

                                      final images =
                                          product[
                                              'images'];

                                      final image =
                                          images
                                                      is List &&
                                                  images
                                                      .isNotEmpty
                                              ? images[
                                                      0]
                                                  .toString()
                                              : '';

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator
                                              .pushReplacementNamed(
                                            context,
                                            AppRoutes
                                                .itemDetail,
                                            arguments:
                                                product[
                                                    'slug'],
                                          );
                                        },
                                        child:
                                            ProductCard(
                                          title:
                                              product[
                                                  'name'],
                                          priceString:
                                              '\$${product['discounted_price'] ?? product['price']}',
                                          imagePathUrl:
                                              image,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ============================================================
                    // BOTTOM CART ACTIONS
                    // ============================================================

                    Container(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.05,
                            ),
                            blurRadius: 4,
                            offset:
                                const Offset(
                              0,
                              -2,
                            ),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            // ==================================================
                            // ADD TO CART
                            // ==================================================

                            Expanded(
                              child:
                                  ElevatedButton
                                      .icon(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFFC62828,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical:
                                        16,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      30,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed:
                                    _addingToCart
                                        ? null
                                        : _addToCart,
                                icon:
                                    _addingToCart
                                        ? const SizedBox(
                                            width:
                                                20,
                                            height:
                                                20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth:
                                                  2,
                                              color:
                                                  Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons
                                                .shopping_cart_outlined,
                                            color:
                                                Colors.white,
                                          ),
                                label: Text(
                                  _addingToCart
                                      ? 'Adding...'
                                      : 'Add to Cart',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        16,
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            // ==================================================
                            // BUY NOW
                            // ==================================================

                            Expanded(
                              child:
                                  ElevatedButton
                                      .icon(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFFC62828,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical:
                                        16,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      30,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed:
                                    _addingToCart
                                        ? null
                                        : () async {
                                            final success =
                                                await _addToCart();

                                            if (!success ||
                                                !mounted) {
                                              return;
                                            }

                                            Navigator
                                                .pushNamed(
                                              context,
                                              AppRoutes
                                                  .cart,
                                            );
                                          },
                                icon:
                                    const Icon(
                                  Icons.wallet,
                                  color:
                                      Colors.white,
                                ),
                                label:
                                    const Text(
                                  'Buy Now',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

      bottomNavigationBar:
          const CustomBottomNavBar(
        activeIndex: 2,
      ),
    );
  }
}