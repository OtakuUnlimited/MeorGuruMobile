import 'package:flutter/material.dart';

import '../../constants.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/cart_item_title.dart';
import '../../backend/services/cart_notifier.dart';
import '../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ============================================================
  // LOAD CART
  // ============================================================

  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
    });

    try {
      await cartNotifier.loadCart();
    } catch (e) {
      debugPrint('Cart loading error: $e');
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  // ============================================================
  // SELECT ALL
  // ============================================================

  bool _isAllSelected(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return false;
    }

    return items.every(
      (item) => item['selected'] == true,
    );
  }

  void _toggleSelectAll(
    List<Map<String, dynamic>> items,
    bool? value,
  ) {
    final selected = value ?? false;

    for (final item in items) {
      item['selected'] = selected;
    }

    setState(() {});
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double _calculateSubtotal(
    List<Map<String, dynamic>> items,
  ) {
    double total = 0;

    for (final item in items) {
      if (item['selected'] != true) {
        continue;
      }

      final price = double.tryParse(
        (
          item['discounted_unit_price'] ??
          item['discounted_price'] ??
          item['unit_price'] ??
          item['price'] ??
          0
        ).toString(),
      ) ??
      0;

      final quantity =
          int.tryParse(
                (item['quantity'] ?? 1).toString(),
              ) ??
              1;

      total += price * quantity;
    }

    return total;
  }

  // ============================================================
  // UPDATE QUANTITY
  // ============================================================

  Future<void> _updateQuantity(
    int itemId,
    int quantity,
  ) async {
    if (quantity < 1) {
      return;
    }

    setState(() {
      _updating = true;
    });

    try {
      await cartNotifier.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint(
        'Quantity update error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _updating = false;
    });
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  Future<void> _removeItem(
    int itemId,
  ) async {
    setState(() {
      _updating = true;
    });

    try {
      await cartNotifier.removeItem(itemId);
    } catch (e) {
      debugPrint(
        'Remove cart item error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _updating = false;
    });
  }

// ============================================================
  // change quantity
  // ============================================================




  Future<void> _changeQuantity(
  int itemId,
  int quantity,
) async {
  setState(() {
    _updating = true;
  });

  try {
    await cartNotifier.updateQuantity(
      itemId: itemId,
      quantity: quantity,
    );
  } catch (e) {
    debugPrint(
      'CHANGE QUANTITY ERROR: $e',
    );
  }

  if (!mounted) return;

  setState(() {
    _updating = false;
  });
}

  // ============================================================
  // DELETE SELECTED
  // ============================================================

  Future<void> _deleteSelectedItems(
    List<Map<String, dynamic>> items,
  ) async {
    final selectedItems = items
        .where(
          (item) => item['selected'] == true,
        )
        .toList();

    if (selectedItems.isEmpty) {
      return;
    }

    setState(() {
      _updating = true;
    });

    try {
      for (final item in selectedItems) {
        final id = int.tryParse(
        (item['item_id'] ?? item['id']).toString(),
      );

        if (id != null) {
          await cartNotifier.removeItem(id);
        }
      }
    } catch (e) {
      debugPrint(
        'Delete selected items error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _updating = false;
    });
  }

  // ============================================================
  // CHECKOUT
  // ============================================================

  void _checkout(
    double subtotal,
  ) {
    if (subtotal <= 0) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.checkout,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavBar(
        title: 'Your Cart',
        style: NavBarStyle.BrandedLight,
        showBack: true,
        showCart: true,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : AnimatedBuilder(
              animation: cartNotifier,
              builder: (
                context,
                child,
              ) {
                final List<Map<String, dynamic>> items =
                    List<Map<String, dynamic>>.from(
                  cartNotifier.items,
                );

                final subtotal =
                    _calculateSubtotal(items);

                final allSelected =
                    _isAllSelected(items);

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Cart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppColors.textDark,
                            ),
                          ),

                          if (items.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color:
                                    AppColors.orangeMain,
                                size: 28,
                              ),
                              onPressed: _updating
                                  ? null
                                  : () =>
                                      _deleteSelectedItems(
                                    items,
                                  ),
                            ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // CART ITEMS
                    // ==================================================

                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Text(
                                'Your cart is empty.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount:
                                  items.length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final item =
                                    items[index];

                                final images = item['images'];

                                final image =
                                    images is List && images.isNotEmpty
                                        ? images.first.toString()
                                        : item['image']?.toString() ?? '';

                                final name =
                                    item['name']
                                            ?.toString() ??
                                        '';


                                final quantity =
                                    int.tryParse(
                                          item['quantity']
                                              .toString(),
                                        ) ??
                                        1;

                               final itemId = int.tryParse(
                                  (
                                    item['item_id'] ??
                                    item['id'] ??
                                    ''
                                  ).toString(),
                                );


                                final originalPrice = double.tryParse(
                                    (
                                      item['unit_price'] ??
                                      item['price'] ??
                                      0
                                    ).toString(),
                                  ) ??
                                  0;

                              final discountedPrice = double.tryParse(
                                    (
                                      item['discounted_unit_price'] ??
                                      item['discounted_price'] ??
                                      originalPrice
                                    ).toString(),
                                  ) ??
                                  originalPrice;

                              final hasDiscount =
                                  discountedPrice < originalPrice;

                              final displayedPrice = hasDiscount
                                  ? '\$${originalPrice.toStringAsFixed(2)} → '
                                      '\$${discountedPrice.toStringAsFixed(2)} AUD'
                                  : '\$${originalPrice.toStringAsFixed(2)} AUD';

                                
                                return CartItemTile(
                                  name: name,
                                  originalPriceString:'\$${originalPrice.toStringAsFixed(2)} AUD',
                                  discountedPriceString: hasDiscount? '\$${discountedPrice.toStringAsFixed(2)} AUD': null,
                                  imageUrl: image,
                                  quantity: quantity,
                                  isSelected:
                                      item['selected'] == true,

                                  // -----------------------------
                                  // CHECKBOX
                                  // -----------------------------

                                  onCheckboxChanged:
                                      (value) {
                                    item['selected'] =
                                        value ?? false;

                                    setState(() {});
                                  },

                                  // -----------------------------
                                  // INCREMENT
                                  // -----------------------------

                                   onIncrement:
                                    itemId == null ||
                                            _updating
                                        ? null
                                        : () async {
                                            await _changeQuantity(
                                              itemId,
                                              quantity + 1,
                                            );
                                          },

                                onDecrement:
                                    itemId == null ||
                                            _updating
                                        ? null
                                        : () async {
                                            if (quantity <=
                                                1) {
                                              return;
                                            }

                                            await _changeQuantity(
                                              itemId,
                                              quantity - 1,
                                            );
                                          },
                                );
                              },
                            ),
                    ),

                    // ==================================================
                    // BOTTOM SUMMARY
                    // ==================================================

                    if (items.isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors
                                  .grey
                                  .shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              // -------------------------------
                              // ALL + SUBTOTAL
                              // -------------------------------

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor:
                                            AppColors
                                                .orangeMain,
                                        value:
                                            allSelected,
                                        onChanged:
                                            (value) =>
                                                _toggleSelectAll(
                                          items,
                                          value,
                                        ),
                                      ),
                                      const Text(
                                        'All',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              16,
                                          color:
                                              AppColors
                                                  .textDark,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      const Text(
                                        'Subtotal',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              16,
                                          color: Colors
                                              .black54,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 20,
                                      ),

                                      Text(
                                        '${subtotal.toStringAsFixed(2)} AUD',
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              AppColors
                                                  .textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              // -------------------------------
                              // CHECKOUT
                              // -------------------------------

                              SizedBox(
                                width:
                                    double.infinity,
                                child:
                                    ElevatedButton.icon(
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFFC62828,
                                    ),
                                    disabledBackgroundColor:
                                        Colors
                                            .grey
                                            .shade300,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 16,
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
                                      subtotal <=
                                              0 ||
                                          _updating
                                      ? null
                                      : () =>
                                          _checkout(
                                        subtotal,
                                      ),

                                  icon:
                                      const Icon(
                                    Icons.wallet,
                                    color:
                                        Colors.white,
                                  ),

                                  label:
                                      const Text(
                                    'Check Out',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      color:
                                          Colors
                                              .white,
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
                );
              },
            ),
    );
  }
}