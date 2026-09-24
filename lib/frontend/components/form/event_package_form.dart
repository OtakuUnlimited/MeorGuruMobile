import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/services/bookings.dart';
import '../../../backend/services/auth_service.dart';
import '../../../backend/utils/auth_guard.dart';
import '../utils/login_required_warning.dart';

class EventPackageForm extends StatefulWidget {
  final Map<String, dynamic> eventPackageData;
  final VoidCallback? onPaymentSubmit;

  const EventPackageForm({
    Key? key,
    required this.eventPackageData,
    this.onPaymentSubmit,
  }) : super(key: key);

  @override
  State<EventPackageForm> createState() =>
      _EventPackageFormState();
}

class _EventPackageFormState extends State<EventPackageForm> {
  // --------------------------------------------------
  // Controllers
  // --------------------------------------------------

  final TextEditingController _eventNameController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _fullNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  // --------------------------------------------------
  // Form state
  // --------------------------------------------------

  bool? _isLoggedIn;
  bool _openingLogin = false;

  String? _selectedCountry = 'Australia';

  String? _selectedGuests = '50';

  String _needGuru = 'Yes';

  String _needCatering = 'Yes';

  String _needPhotography = 'Yes';

  String _needDecoration = 'Yes';

  String _needPujaMaterials = 'Yes';

  String _needVenue = 'Yes';

  String _needGarland = 'Yes';

  String? _selectedCountryCode = '+61';

  bool _agreedToTerms = false;

  bool _submitting = false;

  DateTime? _selectedDate;

  TimeOfDay? _startTime;

  TimeOfDay? _endTime;

  final List<String> _yesNoOptions = [
    'Yes',
    'No',
  ];

  // --------------------------------------------------
  // Init
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();
  _checkLogin();
}

Future<void> _checkLogin() async {
  final loggedIn =
      await AuthService.isLoggedIn();

  if (!mounted) return;

  setState(() {
    _isLoggedIn = loggedIn;
  });

    _eventNameController.text =
        widget.eventPackageData['title']?.toString() ??
            widget.eventPackageData['name']?.toString() ??
            '';
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  void dispose() {
    _eventNameController.dispose();
    _cityController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // Amount
  // --------------------------------------------------

  double get _amount {
    final rawPrice = widget.eventPackageData['price'];

    if (rawPrice == null) {
      return 0;
    }

    return double.tryParse(
          rawPrice.toString().replaceAll(',', ''),
        ) ??
        0;
  }

  String get _formattedAmount {
    return '\$${_amount.toStringAsFixed(
      _amount.truncateToDouble() == _amount ? 0 : 2,
    )}';
  }

  // --------------------------------------------------
  // Date
  // --------------------------------------------------

  String _formatDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // --------------------------------------------------
  // Time
  // --------------------------------------------------

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // --------------------------------------------------
  // Date Picker
  // --------------------------------------------------

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 2,
        now.month,
        now.day,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _openLogin() async {
  if (_openingLogin) return;

  setState(() {
    _openingLogin = true;
  });

  try {
    await requireLogin(
      context,
      message:
          'Please log in to book this Puja.',
    );

    final loggedIn =
        await AuthService.isLoggedIn();

    if (!mounted) return;

    setState(() {
      _isLoggedIn = loggedIn;
    });
  } finally {
    if (mounted) {
      setState(() {
        _openingLogin = false;
      });
    }
  }
}

  // --------------------------------------------------
  // Start Time
  // --------------------------------------------------

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  // --------------------------------------------------
  // End Time
  // --------------------------------------------------

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // --------------------------------------------------
  // Validation
  // --------------------------------------------------

  bool _validateForm() {
    if (_eventNameController.text
        .trim()
        .isEmpty) {
      _showError(
        'Please enter the event name.',
      );
      return false;
    }

    if (_selectedDate == null) {
      _showError(
        'Please select the event date.',
      );
      return false;
    }

    if (_startTime == null) {
      _showError(
        'Please select the start time.',
      );
      return false;
    }

    if (_endTime == null) {
      _showError(
        'Please select the end time.',
      );
      return false;
    }

    if (_fullNameController.text
        .trim()
        .isEmpty) {
      _showError(
        'Please enter your full name.',
      );
      return false;
    }

    if (_emailController.text
        .trim()
        .isEmpty) {
      _showError(
        'Please enter your email address.',
      );
      return false;
    }

    final email =
        _emailController.text.trim();

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email)) {
      _showError(
        'Please enter a valid email address.',
      );
      return false;
    }

    if (_phoneController.text
        .trim()
        .isEmpty) {
      _showError(
        'Please enter your phone number.',
      );
      return false;
    }

    if (_selectedCountry == null ||
        _selectedCountry!
            .trim()
            .isEmpty) {
      _showError(
        'Please select your country.',
      );
      return false;
    }

    if (_amount <= 0) {
      _showError(
        'Invalid event package amount.',
      );
      return false;
    }

    if (!_agreedToTerms) {
      _showError(
        'Please agree to the Terms and Conditions.',
      );
      return false;
    }

    return true;
  }

  // --------------------------------------------------
  // Error
  // --------------------------------------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            const Color(0xFFC62828),
      ),
    );
  }

  // --------------------------------------------------
  // Submit Booking
  // --------------------------------------------------

  Future<void> _submitBooking() async {
    if (_submitting) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      // ------------------------------------------------
      // Get event ID
      // ------------------------------------------------

      final rawEventId =
          widget.eventPackageData['id'];

      debugPrint(
        'EVENT PACKAGE DATA: ${widget.eventPackageData}',
      );

      debugPrint(
        'RAW EVENT ID: $rawEventId',
      );

      final eventId =
          int.tryParse(
        rawEventId.toString(),
      );

      if (eventId == null) {
        throw Exception(
          'Invalid event package ID.',
        );
      }

      // ------------------------------------------------
      // Prepare booking data
      // ------------------------------------------------

      final eventName =
          _eventNameController.text.trim();

      final bookingFor =
          _selectedGuests ?? '';

      final eventDate =
          _formatDate(_selectedDate!);

      final startTime =
          _formatTime(_startTime!);

      final endTime =
          _formatTime(_endTime!);

      final customerName =
          _fullNameController.text.trim();

      final customerEmail =
          _emailController.text.trim();

      final customerPhone =
          '${_selectedCountryCode ?? ''}'
          '${_phoneController.text.trim()}';

      final eventCountry =
          _selectedCountry!;

      final amount = _amount;

      // ------------------------------------------------
      // Debug
      // ------------------------------------------------

      debugPrint(
        '================================',
      );

      debugPrint(
        'EVENT BOOKING SUBMISSION',
      );

      debugPrint(
        'event_id: $eventId',
      );

      debugPrint(
        'event_name: $eventName',
      );

      debugPrint(
        'puja_booking_for: $bookingFor',
      );

      debugPrint(
        'event_date: $eventDate',
      );

      debugPrint(
        'event_start_time: $startTime',
      );

      debugPrint(
        'event_end_time: $endTime',
      );

      debugPrint(
        'customer_name: $customerName',
      );

      debugPrint(
        'customer_email: $customerEmail',
      );

      debugPrint(
        'customer_phone: $customerPhone',
      );

      debugPrint(
        'event_country: $eventCountry',
      );

      debugPrint(
        'amount: $amount',
      );

      debugPrint(
        '================================',
      );

      // ------------------------------------------------
      // Send booking to Laravel
      // ------------------------------------------------

      final response =
          await storeEventBooking(
        eventId: eventId,
        eventName: eventName,
        pujaBookingFor: bookingFor,
        eventDate: eventDate,
        eventStartTime: startTime,
        eventEndTime: endTime,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        eventCountry: eventCountry,
        amount: amount,
      );

      debugPrint(
        '================================',
      );

      debugPrint(
        'EVENT BOOKING RESPONSE',
      );

      debugPrint(
        response.toString(),
      );

      debugPrint(
        '================================',
      );

      // ------------------------------------------------
      // Check response
      // ------------------------------------------------

      if (response == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final stripeUrl =
          response['stripe_url'];

      if (stripeUrl == null ||
          stripeUrl
              .toString()
              .trim()
              .isEmpty) {
        throw Exception(
          'Stripe payment URL was not returned.',
        );
      }

      // ------------------------------------------------
      // Open Stripe
      // ------------------------------------------------

      final uri =
          Uri.tryParse(
        stripeUrl.toString(),
      );

      if (uri == null) {
        throw Exception(
          'Invalid Stripe payment URL.',
        );
      }

      debugPrint(
        'STRIPE URL: $stripeUrl',
      );

      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
          'Could not open payment page.',
        );
      }

      // ------------------------------------------------
      // Callback
      // ------------------------------------------------

      widget.onPaymentSubmit?.call();
    } catch (e, stackTrace) {
      debugPrint(
        '================================',
      );

      debugPrint(
        'EVENT BOOKING ERROR',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      debugPrint(
        '================================',
      );

      if (mounted) {
        _showError(
          'Unable to process booking. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFAFAFA),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          if (_isLoggedIn == null)
      const Padding(
        padding: EdgeInsets.only(
          bottom: 16,
        ),
        child: LinearProgressIndicator(),
      ),

    if (_isLoggedIn == false)
      LoginRequiredWarning(
        message:
            'You need to be logged in to book this Puja and make a payment.',
        loginLoading: _openingLogin,
        onLoginPressed: _openLogin,
      ),

          // ================= EVENT DETAILS =================

          _buildSectionHeader(
            'Event Details',
          ),

          _buildFieldLabel(
            'Event Name:',
          ),

          _buildTextField(
            controller:
                _eventNameController,
          ),

          _buildFieldLabel(
            'Date of Event:',
          ),

          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: _buildTextField(
                hintText:
                    _selectedDate == null
                        ? 'Select date'
                        : _formatDate(
                            _selectedDate!,
                          ),
                suffixIcon:
                    const Icon(
                  Icons.calendar_today,
                  color:
                      Color(0xFFC62828),
                  size: 18,
                ),
              ),
            ),
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'Start Time:',
                    ),
                    GestureDetector(
                      onTap:
                          _selectStartTime,
                      child:
                          AbsorbPointer(
                        child:
                            _buildTextField(
                          hintText:
                              _startTime ==
                                      null
                                  ? '--:--'
                                  : _formatTime(
                                      _startTime!,
                                    ),
                          suffixIcon:
                              const Icon(
                            Icons.access_time,
                            color:
                                Colors.black54,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'End Time:',
                    ),
                    GestureDetector(
                      onTap:
                          _selectEndTime,
                      child:
                          AbsorbPointer(
                        child:
                            _buildTextField(
                          hintText:
                              _endTime ==
                                      null
                                  ? '--:--'
                                  : _formatTime(
                                      _endTime!,
                                    ),
                          suffixIcon:
                              const Icon(
                            Icons.access_time,
                            color:
                                Colors.black54,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildFieldLabel(
            'Country:',
          ),

          _buildDropdownField(
            value:
                _selectedCountry,
            items: const [
              'Australia',
              'Nepal',
              'United States',
              'United Kingdom',
            ],
            onChanged: (val) {
              setState(() {
                _selectedCountry =
                    val;
              });
            },
          ),

          _buildFieldLabel(
            'City:',
            isRequired: false,
          ),

          _buildTextField(
            controller:
                _cityController,
            hintText:
                'Melbourne',
          ),

          _buildFieldLabel(
            'Number of Guests:',
          ),

          _buildDropdownField(
            value:
                _selectedGuests,
            items: const [
              '10',
              '25',
              '50',
              '100',
              '200+',
            ],
            onChanged: (val) {
              setState(() {
                _selectedGuests =
                    val;
              });
            },
          ),

          const SizedBox(
            height: 12,
          ),

          // ================= SERVICE DETAILS =================

          _buildSectionHeader(
            'Service Details:',
          ),

          _buildServiceDropdown(
            'Need Guru?',
            _needGuru,
            (value) {
              setState(() {
                _needGuru =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Catering Service?',
            _needCatering,
            (value) {
              setState(() {
                _needCatering =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Photography?',
            _needPhotography,
            (value) {
              setState(() {
                _needPhotography =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Decoration?',
            _needDecoration,
            (value) {
              setState(() {
                _needDecoration =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Puja Materials?',
            _needPujaMaterials,
            (value) {
              setState(() {
                _needPujaMaterials =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Venue?',
            _needVenue,
            (value) {
              setState(() {
                _needVenue =
                    value!;
              });
            },
          ),

          _buildServiceDropdown(
            'Need Garland?',
            _needGarland,
            (value) {
              setState(() {
                _needGarland =
                    value!;
              });
            },
          ),

          _buildFieldLabel(
            'Additional Notes:',
            isRequired: false,
          ),

          _buildTextField(
            controller:
                _notesController,
            maxLines: 4,
            hintText:
                'Please include additional information, your wish to add.',
          ),

          const SizedBox(
            height: 12,
          ),

          // ================= YOUR DETAILS =================

          _buildSectionHeader(
            'Your Details:',
          ),

          _buildFieldLabel(
            'Full Name:',
          ),

          _buildTextField(
            controller:
                _fullNameController,
          ),

          _buildFieldLabel(
            'Email Address:',
          ),

          _buildTextField(
            controller:
                _emailController,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'Country Code:',
                    ),
                    _buildDropdownField(
                      value:
                          _selectedCountryCode,
                      items: const [
                        '+61',
                        '+977',
                        '+1',
                        '+44',
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCountryCode =
                              val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'Phone Number:',
                    ),
                    _buildTextField(
                      controller:
                          _phoneController,
                      hintText:
                          'Phone Number',
                      keyboardType:
                          TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ================= TERMS =================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value:
                      _agreedToTerms,
                  activeColor:
                      const Color(
                    0xFFFA6400,
                  ),
                  onChanged:
                      (value) {
                    setState(() {
                      _agreedToTerms =
                          value ??
                              false;
                    });
                  },
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Expanded(
                child: Text(
                  'I agree to the MeroGuru Terms and Conditions and Privacy Policy.',
                  style: TextStyle(
                    color:
                        Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          // ================= PAYMENT =================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Amount:',
                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.black87,
                ),
              ),

              Text(
                _formattedAmount,
                style:
                    const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFFC62828),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 48,
            child:
                ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2E2E2E,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                ),
              ),
              onPressed:
                  _agreedToTerms &&
                          !_submitting
                      ? _submitBooking
                      : null,
              child:
                  _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Debit or Credit Card',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // Service Dropdown
  // --------------------------------------------------

  Widget _buildServiceDropdown(
    String label,
    String value,
    ValueChanged<String?>
        onChanged,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          label,
          isRequired: false,
        ),
        _buildDropdownField(
          value: value,
          items:
              _yesNoOptions,
          onChanged:
              onChanged,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Section Header
  // --------------------------------------------------

  Widget _buildSectionHeader(
    String title,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFFFA6400),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        const Divider(
          color: Colors.black12,
          thickness: 1,
          height: 10,
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Field Label
  // --------------------------------------------------

  Widget _buildFieldLabel(
    String label, {
    bool isRequired = true,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 14,
        bottom: 6,
      ),
      child: RichText(
        text: TextSpan(
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF4A4A4A),
          ),
          children: [
            TextSpan(
              text: label,
            ),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style:
                    TextStyle(
                  color:
                      Color(0xFFC62828),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Text Field
  // --------------------------------------------------

  Widget _buildTextField({
    TextEditingController?
        controller,
    String? hintText,
    Widget? suffixIcon,
    int maxLines = 1,
    TextInputType?
        keyboardType,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 2,
      ),
      child:
          TextField(
        controller:
            controller,
        maxLines:
            maxLines,
        keyboardType:
            keyboardType,
        style:
            const TextStyle(
          fontSize: 14,
          color:
              Colors.black87,
        ),
        decoration:
            InputDecoration(
          hintText:
              hintText,
          hintStyle:
              TextStyle(
            color:
                Colors.grey.shade400,
            fontSize:
                14,
          ),
          fillColor:
              Colors.white,
          filled:
              true,
          suffixIcon:
              suffixIcon,
          contentPadding:
              const EdgeInsets
                  .symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              4,
            ),
            borderSide:
                BorderSide(
              color:
                  Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              4,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFFFA6400),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Dropdown
  // --------------------------------------------------

  Widget _buildDropdownField({
    required String? value,
    String? hint,
    required List<String>
        items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Container(
      height: 44,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          4,
        ),
        border:
            Border.all(
          color:
              Colors.grey.shade300,
          width: 1,
        ),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value:
              value,
          hint: hint != null
              ? Text(
                  hint,
                  style:
                      TextStyle(
                    color:
                        Colors.grey.shade500,
                    fontSize:
                        14,
                  ),
                )
              : null,
          isExpanded:
              true,
          icon:
              const Icon(
            Icons.keyboard_arrow_down,
            color:
                Colors.black54,
            size: 20,
          ),
          style:
              const TextStyle(
            color:
                Colors.black87,
            fontSize: 14,
          ),
          items:
              items.map(
            (String item) {
              return DropdownMenuItem<
                  String>(
                value:
                    item,
                child:
                    Text(item),
              );
            },
          ).toList(),
          onChanged:
              onChanged,
        ),
      ),
    );
  }
}