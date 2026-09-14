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
          filled: true,
          fillColor:
              const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: BorderSide.none,
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

                                return CheckoutOrderTile(
                                  title:
                                      item['name']
                                              ?.toString() ??
                                          '',
                                  priceString: _money(
                                    item['discounted_price'] ??
                                        item[
                                            'discounted_unit_price'] ??
                                        item['price'] ??
                                        item['unit_price'],
                                  ),
                                  imageUrl: image,
                                  quantity:
                                      int.tryParse(
                                            item['quantity']
                                                    ?.toString() ??
                                                '1',
                                          ) ??
                                          1,
                                  onRemoveItem:
                                      () {
                                    if (itemId !=
                                        0) {
                                      _removeItem(
                                        itemId,
                                      );
                                    }
                                  },
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
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Discount Voucher',
                                  filled: true,
                                  fillColor: Colors
                                      .grey.shade100,
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(8),
                                    borderSide:
                                        BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed:
                                  _applyingCoupon
                                      ? null
                                      : _applyVoucher,
                              child: _applyingCoupon
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Apply',
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