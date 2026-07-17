import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../backend/services/bookings.dart';
import '../searchable_country_dropdown.dart';
import '../searchable_state_dropdown.dart';
import '../gotra_dropdown.dart';
import '../../../backend/services/api_client.dart';

class OnlinePujaForm extends StatefulWidget {
  final Map<String, dynamic> puja;
  final VoidCallback onPaymentSubmit;

  const OnlinePujaForm({
    Key? key,
    required this.puja,
    required this.onPaymentSubmit,
  }) : super(key: key);

  @override
  State<OnlinePujaForm> createState() => _OnlinePujaFormState();
}

class _OnlinePujaFormState extends State<OnlinePujaForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  String? _pujaBookingFor;
  String? _timezone;
  String? _caste;
  String? _gotra;

  String? deliveryCountry;
  String? deliveryState;

  // Ceremony details
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // Personal information
  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  // Address information
  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController postalCodeController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  // Additional information
  final TextEditingController noteController =
      TextEditingController();

  final ApiClient _client = ApiClient();

  String get _price {
    return widget.puja['price']?.toString() ?? '0';
  }

  int? get _pujaId {
    return int.tryParse(widget.puja['id']?.toString() ?? '');
  }

  // ================= DATE PICKER =================

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();

    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 5,
        now.month,
        now.day,
      ),
    );

    if (selectedDate == null) return;

    setState(() {
      // Laravel accepts this format as a date.
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    });
  }

  // ================= TIME PICKER =================

  Future<void> _selectTime() async {
    FocusScope.of(context).unfocus();

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null || !mounted) return;

    final DateTime time = DateTime(
      2000,
      1,
      1,
      selectedTime.hour,
      selectedTime.minute,
    );

    setState(() {
      // Example: 14:30
      timeController.text = DateFormat('HH:mm').format(time);
    });
  }

  // ================= VALIDATION =================

  bool _validateBooking() {
    FocusScope.of(context).unfocus();

    if (_pujaId == null) {
      _showMessage(
        'Invalid Puja ID.',
        isError: true,
      );
      return false;
    }

    if (_pujaBookingFor == null || _pujaBookingFor!.isEmpty) {
      _showMessage(
        'Please select who the Puja is being booked for.',
        isError: true,
      );
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      _showMessage(
        'Please select the date of the Puja.',
        isError: true,
      );
      return false;
    }

    if (timeController.text.trim().isEmpty) {
      _showMessage(
        'Please select the time of the Puja.',
        isError: true,
      );
      return false;
    }

    if (_timezone == null || _timezone!.isEmpty) {
      _showMessage(
        'Please select a timezone.',
        isError: true,
      );
      return false;
    }

    if (firstNameController.text.trim().isEmpty) {
      _showMessage(
        'Please enter your first name.',
        isError: true,
      );
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      _showMessage(
        'Please enter your last name.',
        isError: true,
      );
      return false;
    }

    final String email = emailController.text.trim();

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (email.isEmpty || !emailPattern.hasMatch(email)) {
      _showMessage(
        'Please enter a valid email address.',
        isError: true,
      );
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage(
        'Please enter your phone number.',
        isError: true,
      );
      return false;
    }

    if (deliveryCountry == null || deliveryCountry!.isEmpty) {
      _showMessage(
        'Please select your country.',
        isError: true,
      );
      return false;
    }

    if (deliveryCountry == 'Australia' &&
        (deliveryState == null || deliveryState!.isEmpty)) {
      _showMessage(
        'Please select your Australian state.',
        isError: true,
      );
      return false;
    }

    if (postalCodeController.text.trim().isEmpty) {
      _showMessage(
        'Please enter the ZIP/postal code.',
        isError: true,
      );
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      _showMessage(
        'Please enter the full address.',
        isError: true,
      );
      return false;
    }

    if (!_agreedToTerms) {
      _showMessage(
        'Please accept the Terms and Conditions.',
        isError: true,
      );
      return false;
    }

    final double? amount = double.tryParse(_price);

    if (amount == null || amount < 1) {
      _showMessage(
        'The Puja price is invalid.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // ================= MESSAGE =================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }
    // ================= SUBMIT BOOKING =================

  Future<void> submitBooking() async {
    if (_isSubmitting) return;

    if (!_validateBooking()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Executes the callback supplied by OnlinePujaOrderScreen.
      widget.onPaymentSubmit();

      final dynamic response = await createPujaBooking(
        pujaId: _pujaId!,
        bookingFor: _pujaBookingFor!,
        date: dateController.text.trim(),
        time: timeController.text.trim(),
        timezone: _timezone!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        country: deliveryCountry!,
        amount: _price,

        // Optional fields
        caste: _emptyToNull(_caste),
        gotra: _emptyToNull(_gotra),
        address: _emptyToNull(addressController.text),
        city: _emptyToNull(cityController.text),
        state: _emptyToNull(deliveryState),

        // Your UI uses City/Suburb as one field.
        suburb: _emptyToNull(cityController.text),

        postalCode: _emptyToNull(postalCodeController.text),
        note: _emptyToNull(noteController.text),
      );

      if (response == null || response is! Map) {
        throw Exception('The server returned an invalid response.');
      }

      final bool success =
          response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == '200';

      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Unable to create the Puja booking.',
        );
      }

      final int? bookingId = int.tryParse(
        response['booking_id']?.toString() ?? '',
      );

      final String clientSecret =
          response['client_secret']?.toString() ?? '';

      if (bookingId == null) {
        throw Exception(
          'The booking was created without a valid booking ID.',
        );
      }

      if (clientSecret.isEmpty) {
        throw Exception(
          'The server did not return a Stripe client secret.',
        );
      }

      await _makePayment(
        clientSecret: clientSecret,
        bookingId: bookingId,
      );
    } on stripe.StripeException catch (error) {
      final String message =
          error.error.localizedMessage ??
          'The payment was cancelled.';

      _showMessage(
        message,
        isError: true,
      );
    } catch (error, stackTrace) {
      debugPrint('Puja booking error: $error');
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        _readableError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ================= STRIPE PAYMENT =================

  Future<void> _makePayment({
    required String clientSecret,
    required int bookingId,
  }) async {
    await stripe.Stripe.instance.initPaymentSheet(
      paymentSheetParameters:
          stripe.SetupPaymentSheetParameters(
        merchantDisplayName: 'Mero Guru',
        paymentIntentClientSecret: clientSecret,

        // Allows the Payment Sheet to use the colors of the app.
        style: ThemeMode.system,
      ),
    );

    await stripe.Stripe.instance.presentPaymentSheet();

    if (!mounted) return;

    _showMessage('Payment submitted successfully.');

    /*
     * Do not mark the booking as paid from Flutter.
     *
     * Stripe sends payment_intent.succeeded to the Laravel webhook.
     * Laravel then changes:
     *
     * payment_status = Paid
     * status = Confirmed
     *
     * Flutter only verifies the updated status.
     */
    final bool paymentVerified =
        await _waitForPaymentVerification(bookingId);

    if (!mounted) return;

    if (paymentVerified) {
      _showMessage('Payment verified successfully.');

      Navigator.pushReplacementNamed(
        context,
        '/payment-success',
        arguments: {
          'booking_id': bookingId,
          'booking_type': 'puja',
        },
      );
    } else {
      _showMessage(
        'Payment was submitted, but verification is taking longer than '
        'expected. Please check your booking status shortly.',
        isError: true,
      );
    }
  }

  // ================= PAYMENT VERIFICATION =================

  Future<bool> _waitForPaymentVerification(
    int bookingId,
  ) async {
    // Attempts verification 10 times, once every 2 seconds.
    for (int attempt = 0; attempt < 10; attempt++) {
      await Future<void>.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return false;

      try {
        /*
         * This assumes your Laravel route is:
         *
         * GET mobile/payment-status/{bookingId}
         *
         * and returns:
         *
         * {
         *   "payment_status": "Paid",
         *   "status": "Confirmed"
         * }
         */
        final dynamic response = await _client.get(
          'mobile/payment-status/$bookingId',
        );

        if (response is Map) {
          final String paymentStatus =
              response['payment_status']
                  ?.toString()
                  .toLowerCase() ??
              '';

          if (paymentStatus == 'paid') {
            return true;
          }

          final String bookingStatus =
              response['status']
                  ?.toString()
                  .toLowerCase() ??
              '';

          if (bookingStatus == 'cancelled' ||
              bookingStatus == 'canceled') {
            return false;
          }
        }
      } catch (error) {
        /*
         * A temporary status-request failure should not immediately
         * fail the payment. The loop will try again.
         */
        debugPrint(
          'Payment verification attempt '
          '${attempt + 1} failed: $error',
        );
      }
    }

    return false;
  }

  // ================= HELPERS =================

  String? _emptyToNull(String? value) {
    final String result = value?.trim() ?? '';

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  String _readableError(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }

    return message;
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    cityController.dispose();
    postalCodeController.dispose();
    addressController.dispose();
    noteController.dispose();

    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= CEREMONY DETAILS =================

            _buildSectionHeader('Ceremony Details'),

            _buildFieldLabel('Puja Booking for:'),
            _buildDropdownField(
              value: _pujaBookingFor,
              hint: 'Select',
              items: const [
                'Myself',
                'Family Member',
                'Friend',
              ],
              onChanged: (value) {
                setState(() {
                  _pujaBookingFor = value;
                });
              },
            ),

            // Date and time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Date of puja:'),
                      _buildTextField(
                        controller: dateController,
                        hintText: 'YYYY-MM-DD',
                        readOnly: true,
                        onTap: _selectDate,
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFC62828),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Time of puja:'),
                      _buildTextField(
                        controller: timeController,
                        hintText: '--:--',
                        readOnly: true,
                        onTap: _selectTime,
                        suffixIcon: const Icon(
                          Icons.access_time,
                          color: Colors.black54,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildFieldLabel('Timezone:'),
            _buildDropdownField(
              value: _timezone,
              hint: 'Select Timezone',
              items: const [
                'Asia/Kathmandu',
                'Australia/Sydney',
                'Australia/Melbourne',
                'America/New_York',
                'America/Los_Angeles',
                'Europe/London',
                'Europe/Paris',
                'Asia/Kolkata',
                'Asia/Dubai',
                'Asia/Tokyo',
              ],
              onChanged: (value) {
                setState(() {
                  _timezone = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // ================= PERSONAL INFORMATION =================

            _buildSectionHeader('Personal Information'),

            _buildFieldLabel('First Name:'),
            _buildTextField(
              controller: firstNameController,
              hintText: 'First name',
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
            ),

            _buildFieldLabel('Last Name:'),
            _buildTextField(
              controller: lastNameController,
              hintText: 'Last name',
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
            ),

            _buildFieldLabel(
              'Caste:',
              isRequired: false,
            ),
            _buildDropdownField(
              value: _caste,
              hint: 'Select',
              items: const [
                'Brahman',
                'Chhetri',
                'Newar',
                'Gurung',
                'Magar',
                'Rai',
                'Limbu',
                'Tamang',
                'Tharu',
                'Other',
              ],
              onChanged: (value) {
                setState(() {
                  _caste = value;
                });
              },
            ),

            _buildFieldLabel(
              'Gotra:',
              isRequired: false,
            ),

            GotraDropdown(
              initialValue: _gotra,
              onChanged: (value) {
                setState(() {
                  _gotra = value;
                });
              },
            ),

            _buildFieldLabel('Email Address:'),
            _buildTextField(
              controller: emailController,
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
            ),

            _buildFieldLabel('Phone Number:'),

            IntlPhoneField(
              initialCountryCode: 'NP',
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color(0xFFFA6400),
                    width: 1,
                  ),
                ),
              ),
              onChanged: (phone) {
                /*
                 * Stores the complete international phone number.
                 * Example: +9779812345678
                 */
                phoneController.text = phone.completeNumber;
              },
            ),

            // ================= ADDRESS INFORMATION =================

            _buildFieldLabel('Country:'),

            Column(
              children: [
                SearchableCountryDropdown(
                  label: '',
                  initialCountry: deliveryCountry,
                  onChanged: (country) {
                    setState(() {
                      deliveryCountry = country;

                      if (country != 'Australia') {
                        deliveryState = null;
                      }
                    });
                  },
                ),

                if (deliveryCountry == 'Australia')
                  const SizedBox(height: 16),

                if (deliveryCountry == 'Australia')
                  SearchableStateDropdown(
                    country: 'Australia',
                    initialState: deliveryState,
                    onChanged: (state) {
                      setState(() {
                        deliveryState = state;
                      });
                    },
                  ),
              ],
            ),

            _buildFieldLabel(
              'City/Suburb:',
              isRequired: false,
            ),
            _buildTextField(
              controller: cityController,
              hintText: 'City or suburb',
              textCapitalization: TextCapitalization.words,
            ),

            _buildFieldLabel('Zip/Postal Code:'),
            _buildTextField(
              controller: postalCodeController,
              hintText: 'ZIP/postal code',
              keyboardType: TextInputType.text,
            ),

            _buildFieldLabel('Full Address:'),
            _buildTextField(
              controller: addressController,
              hintText: 'Enter your complete address',
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            // ================= ADDITIONAL NOTES =================

            _buildSectionHeader('Additional Notes'),

            const SizedBox(height: 8),

            _buildTextField(
              controller: noteController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              hintText:
                  'Please include additional information, your wishes '
                  'from the puja, sankalpa, or if you would like to '
                  'include additional people in the puja '
                  '(for example, your child).',
            ),

            const SizedBox(height: 20),

            // ================= TERMS =================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    activeColor: const Color(0xFFFA6400),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'I agree to the MeroGuru ',
                        ),
                        TextSpan(
                          text: 'Terms and Conditions ',
                          style: TextStyle(
                            color: Color(0xFFFA6400),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: 'and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xFFFA6400),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ================= PRICE =================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Amount:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$$_price',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================= SUBMIT BUTTON =================

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2E2E),
                  disabledBackgroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed:
                    !_agreedToTerms || _isSubmitting
                        ? null
                        : submitBooking,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Debit or Credit Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION HEADER =================

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFA6400),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(
          color: Colors.black12,
          thickness: 1,
          height: 10,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ================= FIELD LABEL =================

  Widget _buildFieldLabel(
    String label, {
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 6,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
          children: [
            TextSpan(text: label),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFC62828),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    Widget? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          fillColor: Colors.white,
          filled: true,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xFFFA6400),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdownField({
    required String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 20,
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: _isSubmitting ? null : onChanged,
        ),
      ),
    );
  }
}