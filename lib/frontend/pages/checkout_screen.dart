import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../backend/services/shop_service.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/checkout_order_tile.dart';
import '../components/shop/checkout_summary_card.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() =>
      _CheckOutScreenState();
}

class _CheckOutScreenState
    extends State<CheckOutScreen> {
  final ShopService _shopService = ShopService();

  final _formKey = GlobalKey<FormState>();

  final _firstNameController =
      TextEditingController();

  final _lastNameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _streetController =
      TextEditingController();

  final _cityController =
      TextEditingController();

  final _countryController =
      TextEditingController();

  final _voucherController =
      TextEditingController();

  bool _loading = true;
  bool _applyingCoupon = false;

  String? _error;
  bool _updatingItem = false;

  List<Map<String, dynamic>> _checkoutItems = [];

  double _subtotal = 0;
  double _discount = 0;
  double _deliveryFee = 0;
  double _tax = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckout();
    });
  }

  Future<void> _loadCheckout({
    String? couponCode,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await _shopService.getCart(
        couponCode: couponCode,
      );

      final rawCart = response['cart'];

      if (!mounted) return;

      setState(() {
        _checkoutItems = rawCart is List
            ? rawCart
                .map<Map<String, dynamic>>(
                  (item) =>
                      Map<String, dynamic>.from(
                    item as Map,
                  ),
                )
                .toList()
            : [];

        _subtotal = _toDouble(
          response['subtotal'],
        );

        _discount = _toDouble(
              response['total_discount_amount'],
            ) +
            _toDouble(
              response['couponDiscount'],
            );

        _deliveryFee = _toDouble(
          response['delivery_charge'],
        );

        _tax = _toDouble(
          response['tax_amount'],
        );

        _total = _toDouble(
          response['total_amount'],
        );

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }

  String _money(dynamic value) {
    return '${_toDouble(value).toStringAsFixed(2)} AUD';
  }

  Future<void> _removeItem(
    int itemId,
  ) async {
    try {
      await _shopService.removeCartItem(
        itemId,
      );

      await _loadCheckout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not remove item: $e',
          ),
        ),
      );
    }
  }

  Future<void> _updateQuantity({
  required int itemId,
  required int quantity,
}) async {
  if (itemId == 0 || quantity < 1 || _updatingItem) {
    return;
  }

  setState(() {
    _updatingItem = true;
  });

  try {
    await _shopService.updateCartItem(
      itemId: itemId,
      quantity: quantity,
    );

    await _loadCheckout(
      couponCode:
          _voucherController.text.trim().isEmpty
              ? null
              : _voucherController.text.trim(),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(
          e.toString(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _updatingItem = false;
      });
    }
  }
}

  Future<void> _applyVoucher() async {
    final code =
        _voucherController.text.trim();

    if (code.isEmpty) return;

    setState(() {
      _applyingCoupon = true;
    });

    await _loadCheckout(
      couponCode: code,
    );

    if (!mounted) return;

    setState(() {
      _applyingCoupon = false;
    });
  }

  void _proceedToPay() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkoutItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your cart is empty.',
          ),
        ),
      );

      return;
    }

    final checkoutData = {
      'first_name':
          _firstNameController.text.trim(),
      'last_name':
          _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'street':
          _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'country':
          _countryController.text.trim(),
      'coupon_code':
          _voucherController.text.trim(),
      'total': _total,
      'items': _checkoutItems,
    };

    debugPrint(
      'CHECKOUT DATA: $checkoutData',
    );

    // Connect your payment/order API here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Checkout details are ready.',
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },
        decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 12,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.orangeMain,
            width: 2,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: 
            const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _voucherController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopNavBar(
        title: 'Check Out',
        style: NavBarStyle.BrandedLight,
        showBack: true,
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadCheckout,
                        child:
                            const Text('Try again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_checkoutItems.isEmpty)
                          const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(30),
                              child: Text(
                                'Your cart is empty',
                              ),
                            ),
                          )
                        else
                          Container(
                            constraints:
                                const BoxConstraints(
                                  minHeight: 200,
                              maxHeight: 230,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                color: Colors
                                    .grey.shade200,
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  _checkoutItems
                                      .length,
                              itemBuilder:
                                  (context, index) {
                                final item =
                                    _checkoutItems[
                                        index];

                                final itemId =
                                    int.tryParse(
                                          item['item_id']
                                                  ?.toString() ??
                                              '',
                                        ) ??
                                        0;

                                final image =
                                    item['image']
                                            ?.toString() ??
                                        '';

                               final rawImages =
                                  item['images'] ?? item['image'];

                              String imageUrl = '';

                              if (rawImages is List &&
                                  rawImages.isNotEmpty) {
                                imageUrl =
                                    rawImages.first?.toString() ?? '';
                              } else if (rawImages is String &&
                                  rawImages.startsWith('http')) {
                                imageUrl = rawImages;
                              }

                              final englishName =
                                  item['english_name']
                                      ?.toString()
                                      .trim() ??
                                  '';

                              final localName =
                                  item['name']?.toString().trim() ?? '';

                              final originalPrice = _toDouble(
                                item['unit_price'] ?? item['price'],
                              );

                              final discountedPrice = _toDouble(
                                item['discounted_unit_price'] ??
                                    item['discounted_price'] ??
                                    originalPrice,
                              );

                              final hasDiscount =
                                  discountedPrice < originalPrice;

                              final quantity = int.tryParse(
                                item['quantity']?.toString() ?? '1',
                              ) ??
                              1;

                          return CheckoutOrderTile(
                            englishName: englishName,
                            localName: localName,
                            originalPriceString: _money(originalPrice),
                            discountedPriceString: hasDiscount
                                ? _money(discountedPrice)
                                : null,
                            imageUrl: imageUrl,
                            quantity: quantity,
                            onDecrement:
                                _updatingItem || quantity <= 1
                                    ? null
                                    : () => _updateQuantity(
                                          itemId: itemId,
                                          quantity: quantity - 1,
                                        ),
                            onIncrement: _updatingItem
                                ? null
                                : () => _updateQuantity(
                                      itemId: itemId,
                                      quantity: quantity + 1,
                                    ),
                            onRemoveItem: _updatingItem || itemId == 0
                                ? null
                                : () => _removeItem(itemId),
                          );
                              },
                            ),
                          ),

                        const SizedBox(height: 24),

                        const Text(
                          'Personal Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _input(
                          label: 'First Name',
                          placeholder: 'John',
                          controller:
                              _firstNameController,
                        ),
                        _input(
                          label: 'Last Name',
                          placeholder: 'Doe',
                          controller:
                              _lastNameController,
                        ),
                        _input(
                          label: 'Email',
                          placeholder:
                              'youremail@example.com',
                          controller:
                              _emailController,
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                        ),
                        _input(
                          label: 'Phone No.',
                          placeholder:
                              '+977 9860000000',
                          controller:
                              _phoneController,
                          keyboardType:
                              TextInputType.phone,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _input(
                          label: 'Street Address',
                          placeholder:
                              'Street and number',
                          controller:
                              _streetController,
                        ),
                        _input(
                          label: 'City',
                          placeholder: 'City',
                          controller:
                              _cityController,
                        ),
                        _input(
                          label: 'Country',
                          placeholder: 'Country',
                          controller:
                              _countryController,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    _voucherController,
                                decoration: InputDecoration(
                                  hintText: 'Discount Voucher',
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.orangeMain,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _applyingCoupon
                                    ? null
                                    : _applyVoucher,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFC62828),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFC62828)
                                          .withOpacity(0.6),
                                  disabledForegroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                ),
                                child: _applyingCoupon
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Apply',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        CheckoutSummaryCard(
                          subtotal:
                              _money(_subtotal),
                          discount:
                              '-${_money(_discount)}',
                          deliveryFee:
                              _money(_deliveryFee),
                          tax: _money(_tax),
                          total: _money(_total),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                _checkoutItems.isEmpty
                                    ? null
                                    : _proceedToPay,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFFC62828,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 16,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(30),
                              ),
                            ),
                            icon: const Icon(
                              Icons.wallet,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Proceed to Pay',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar:
          const CustomBottomNavBar(
        activeIndex: 2,
      ),
    );
  }
}