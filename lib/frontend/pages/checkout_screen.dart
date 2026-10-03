import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../../backend/services/shop_service.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/checkout_order_tile.dart';
import '../components/shop/checkout_summary_card.dart';
import '../components/searchable_state_dropdown.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../backend/services/cart_notifier.dart';
import '../../routes/app_routes.dart';

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

  bool _processingPayment = false;

final _fullNameController =
    TextEditingController();

final _emailController =
    TextEditingController();

final _phoneController =
    TextEditingController();

final _suburbController =
    TextEditingController();

final _postcodeController =
    TextEditingController();

final _deliveryAddressController =
    TextEditingController();

final _voucherController =
    TextEditingController();

static const String _deliveryCountry =
    'Australia';

static const String _countryCode = '+61';

String? _deliveryState;


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
  String _formattedAustralianPhone() {
  var phone = _phoneController.text
      .replaceAll(RegExp(r'\D'), '');

  // 0412 345 678 becomes +61 412 345 678.
  if (phone.startsWith('0')) {
    phone = phone.substring(1);
  }

  return '+61$phone';
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

void _showError(String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void _showSuccess(String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  Future<void> _proceedToPay() async {
  if (_processingPayment) return;

  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_deliveryState == null ||
      _deliveryState!.trim().isEmpty) {
    _showError(
      'Please select an Australian state.',
    );
    return;
  }

  if (_checkoutItems.isEmpty) {
    _showError('Your cart is empty.');
    return;
  }

  setState(() {
    _processingPayment = true;
  });

  try {
    final response =
        await _shopService.createCheckout(
      receiverName:
          _fullNameController.text,
      receiverEmail:
          _emailController.text,
      receiverPhone:
          _formattedAustralianPhone(),
      address:
          _deliveryAddressController.text,
      country: _deliveryCountry,
      state: _deliveryState,
      suburb: _suburbController.text,
      postCode: _postcodeController.text,
      couponCode:
          _voucherController.text.trim().isEmpty
              ? null
              : _voucherController.text.trim(),
    );

    debugPrint(
      'ECOMMERCE CHECKOUT RESPONSE: $response',
    );

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Checkout could not be started.',
      );
    }

    final clientSecret =
        response['client_secret']?.toString();

    final publishableKey =
        response['publishable_key']?.toString();

    final orderNumber =
        response['order_number']?.toString();

    if (clientSecret == null ||
        clientSecret.isEmpty) {
      throw Exception(
        'Stripe client secret is missing.',
      );
    }

    /*
     * Use the publishable key returned by the same
     * Laravel server that created the PaymentIntent.
     * This prevents Stripe account mismatch errors.
     */
    if (publishableKey != null &&
        publishableKey.isNotEmpty &&
        Stripe.publishableKey != publishableKey) {
      Stripe.publishableKey = publishableKey;
      Stripe.urlScheme = 'meroguru';

      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters:
          SetupPaymentSheetParameters(
        paymentIntentClientSecret:
            clientSecret,
        merchantDisplayName: 'Mero Guru',
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    if (!mounted) return;

    _showSuccess(
      orderNumber == null
          ? 'Payment completed successfully.'
          : 'Order $orderNumber placed successfully.',
    );

    /*
     * Refresh the cart after Laravel/webhook clears it.
     */
    await cartNotifier.refresh();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shop,
      (route) => route.isFirst,
    );
  } on StripeException catch (error) {
    if (!mounted) return;

    if (error.error.code ==
        FailureCode.Canceled) {
      _showError('Payment was cancelled.');
      return;
    }

    _showError(
      error.error.localizedMessage ??
          'Stripe payment failed.',
    );
  } catch (error, stackTrace) {
    debugPrint(
      'ECOMMERCE PAYMENT ERROR: $error',
    );
    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    var message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('HttpException: ', '');

    _showError(message);
  } finally {
    if (mounted) {
      setState(() {
        _processingPayment = false;
      });
    }
  }
}

  Widget _input({
  required String label,
  required String placeholder,
  required TextEditingController controller,
  TextInputType keyboardType =
      TextInputType.text,
  List<TextInputFormatter>?
      inputFormatters,
  int? maxLength,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16,
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator ??
          (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return '$label is required';
            }

            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        counterText: '',
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 12,
        ),
        enabledBorder:
            const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
            width: 1,
          ),
        ),
        focusedBorder:
            const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.orangeMain,
            width: 2,
          ),
        ),
        errorBorder:
            const UnderlineInputBorder(
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

Widget _fixedCountryField() {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16,
    ),
    child: TextFormField(
      initialValue: _deliveryCountry,
      readOnly: true,
      enableInteractiveSelection: false,
      decoration: const InputDecoration(
        labelText: 'Country',
        suffixIcon: Icon(
          Icons.lock_outline,
          size: 18,
        ),
        contentPadding:
            EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 12,
        ),
        enabledBorder:
            UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
          ),
        ),
        focusedBorder:
            UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.orangeMain,
            width: 2,
          ),
        ),
      ),
    ),
  );
}

Widget _australianPhoneField() {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              height: 55,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    '🇦🇺',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(width: 7),
                  Text(
                    _countryCode,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType:
                    TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                  LengthLimitingTextInputFormatter(
                    10,
                  ),
                ],
                validator: (value) {
                  final phone =
                      value?.trim() ?? '';

                  if (phone.isEmpty) {
                    return 'Phone number is required';
                  }

                  if (phone.length < 9 ||
                      phone.length > 10) {
                    return 'Enter a valid Australian phone number';
                  }

                  return null;
                },
                decoration:
                    const InputDecoration(
                  hintText: '4XX XXX XXX',
                  counterText: '',
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 16,
                  ),
                  enabledBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          Color(0xFFBDBDBD),
                    ),
                  ),
                  focusedBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          AppColors.orangeMain,
                      width: 2,
                    ),
                  ),
                  errorBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedErrorBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  @override
void dispose() {
  _fullNameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _suburbController.dispose();
  _postcodeController.dispose();
  _deliveryAddressController.dispose();
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
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _input(
                          label: 'Full Name',
                          placeholder: 'Enter your full name',
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                        ),

                        _input(
                          label: 'Email',
                          placeholder: 'youremail@example.com',
                          controller: _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Email is required';
                            }

                            final emailPattern = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!emailPattern.hasMatch(email)) {
                              return 'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        _australianPhoneField(),

                        const SizedBox(height: 12),

                        const Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _fixedCountryField(),

                        SearchableStateDropdown(
                          country: _deliveryCountry,
                          initialState: _deliveryState,
                          onChanged: (state) {
                            setState(() {
                              _deliveryState = state;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _input(
                          label: 'Suburb',
                          placeholder: 'Enter your suburb',
                          controller: _suburbController,
                        ),

                        _input(
                          label: 'Postcode',
                          placeholder: 'Enter postcode',
                          controller: _postcodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (value) {
                            final postcode = value?.trim() ?? '';

                            if (postcode.isEmpty) {
                              return 'Postcode is required';
                            }

                            if (!RegExp(r'^\d{4}$')
                                .hasMatch(postcode)) {
                              return 'Australian postcode must contain 4 digits';
                            }

                            return null;
                          },
                        ),

                        _input(
                          label: 'Delivery Address',
                          placeholder:
                              'House number and street address',
                          controller:
                              _deliveryAddressController,
                        ),

                        const SizedBox(height: 12),

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
                            _checkoutItems.isEmpty ||
                                    _processingPayment
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