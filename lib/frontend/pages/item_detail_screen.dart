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
import '../../backend/utils/auth_guard.dart';

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

  Future<void> _openCart() async {
  final allowed = await requireLogin(
    context,
    message:
        'You need to be logged in to view your cart.',
  );

  if (!allowed || !mounted) return;

  Navigator.pushNamed(
    context,
    AppRoutes.cart,
  );
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
  if (_product == null ||
      _addingToCart) {
    return false;
  }

  final allowed = await requireLogin(
    context,
    message:
        'You need to be logged in to add items to your cart.',
  );

  if (!allowed || !mounted) {
    return false;
  }

  final itemId = int.tryParse(
    _product!['id']?.toString() ?? '',
  );

  if (itemId == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red.shade700,
          content: const Text(
            'Invalid product ID.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

    return false;
  }

  setState(() {
    _addingToCart = true;
  });

  try {
    final success =
        await cartNotifier.addToCart(
      itemId: itemId,
      quantity: _itemQuantity,
    );

    if (!mounted) {
      return success;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
          content: Text(
            success
                ? 'Item added to cart.'
                : cartNotifier.error ??
                    'Could not add item to cart.',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

    return success;
  } catch (e) {
    if (!mounted) return false;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red.shade700,
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

    return false;
  } finally {
    if (mounted) {
      setState(() {
        _addingToCart = false;
      });
    }
  }
}

  double _price(
      Map<String, dynamic> product,
    ) {
      return double.tryParse(
            product['price']?.toString() ?? '0',
          ) ??
          0;
    }

    double? _discountedPrice(
      Map<String, dynamic> product,
    ) {
      return double.tryParse(
        product['discounted_price']?.toString() ??
            '',
      );
    }

    bool _inStock(
      Map<String, dynamic> product,
    ) {
      final stock = product['in_stock'];

      return stock == true ||
          stock == 1 ||
          stock?.toString() == '1';
    }

    Widget _productCard(
      Map<String, dynamic> product, {
      double? width,
    }) {
      final originalPrice = _price(product);
      final discountedPrice =
          _discountedPrice(product);

      final hasDiscount =
          discountedPrice != null &&
          discountedPrice < originalPrice;

      final discount = product['discount'];

      final discountType =
          discount is Map
              ? discount['discount_type']?.toString().toLowerCase()
              : null;

      final discountValue = double.tryParse(
        discount is Map
            ? discount['discount_value']?.toString() ?? '0'
            : '0',
      );

      final discountPercentage =
          discountType == 'percentage' &&
                  discountValue != null &&
                  discountValue > 0
              ? discountValue
              : null;

      final discountAmount =
          discountType == 'amount' &&
                  discountValue != null &&
                  discountValue > 0
              ? discountValue
              : null;

      final images = product['images'];

      final image =
          images is List && images.isNotEmpty
              ? images.first.toString()
              : '';

      return ProductCard(
        width: width,

        title:
            product['name']?.toString() ?? '',

        englishName:
            product['english_name']?.toString(),

        priceString:
            '\$${originalPrice.toStringAsFixed(2)} AUD',

        discountedPriceString: hasDiscount
            ? '\$${discountedPrice!.toStringAsFixed(2)} AUD'
            : null,

        discountPercentage: hasDiscount
                      ? (product['discount']?['type']?.toString() =='percentage'
                          ? double.tryParse(
                              product['discount']?['value']
                                  ?.toString() ?? '0',
                            )
                          : null)
                        : null,
                        discountAmount: hasDiscount
                      ? (product['discount']?['type']?.toString() =='fixed'
                          ? double.tryParse(
                              product['discount']?['value']
                                  ?.toString() ?? '0',
                            )
                          : null)
                        : null,

        imagePathUrl: image,

        inStock: _inStock(product),
      );
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
        title: 'Product Details',
        style:
            NavBarStyle.Shop,
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
                                              .orangeMain,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    _product![
                                        'english_name'],
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight.w400,
                                      color:
                                          AppColors
                                              .textDark,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Builder(
                                    builder: (context) {
                                      final originalPrice =
                                          _price(_product!);

                                      final discountedPrice =
                                          _discountedPrice(_product!);

                                      final hasDiscount =
                                          discountedPrice != null &&
                                          discountedPrice < originalPrice;

                                      final inStock =
                                          _inStock(_product!);

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: hasDiscount
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '\$${originalPrice.toStringAsFixed(2)} AUD',
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        '\$${discountedPrice.toStringAsFixed(2)} AUD',
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 24,
                                                          color: AppColors
                                                              .orangeMain,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    '\$${originalPrice.toStringAsFixed(2)} AUD',
                                                    style:
                                                        const TextStyle(
                                                      fontSize: 24,
                                                      color:
                                                          AppColors.orangeMain,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: inStock
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              inStock
                                                  ? 'In Stock'
                                                  : 'Out of Stock',
                                              style: TextStyle(
                                                color: inStock
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
                                             _productCard(
                                                product,
                                                width: 150,
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
                                            _productCard(product),
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
                                     _addingToCart || !_inStock(_product!)
                                        ? null
                                        : () async {
                                            final success =
                                                await _addToCart();

                                            if (!success ||
                                                !mounted) {
                                              return;
                                            }

                                            _openCart();
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