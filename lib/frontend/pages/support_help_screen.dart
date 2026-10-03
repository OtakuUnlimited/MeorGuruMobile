import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../constants.dart';
import '../../backend/services/faq_services.dart';
import '../components/top_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../backend/services/stripe_payment_services.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({Key? key}) : super(key: key);

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen> {
  final FaqService _faqService = FaqService();
 // Default selected 50$
  String _selectedCountryCode = '+977';

  bool _loadingFaqs = true;
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allFaqs = [];
  List<Map<String, dynamic>> _displayedFaqs = [];
  final TextEditingController _donationController =
    TextEditingController();

  final List<double> _donationAmounts = [
  10,
  15,
  50,
  ];

  int _selectedDonationIndex = 2;
  bool _processingDonation = false;

  @override
  void initState() {
    super.initState();
    _loadFaqData();
  }

  double? _getDonationAmount() {
  final customText =
      _donationController.text.trim();

  if (customText.isNotEmpty) {
    final customAmount =
        double.tryParse(customText);

    if (customAmount != null &&
        customAmount > 0) {
      return customAmount;
    }

    return null;
  }

  if (_selectedDonationIndex >= 0 &&
      _selectedDonationIndex <
          _donationAmounts.length) {
    return _donationAmounts[
        _selectedDonationIndex];
  }

  return null;
}

void _showErrorMessage(String message) {
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void _showSuccessMessage(String message) {
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
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

Future<void> _makeDonation() async {
  if (_processingDonation) return;

  final amount = _getDonationAmount();

  if (amount == null || amount < 1) {
    _showErrorMessage(
      'Please select or enter a valid donation amount.',
    );
    return;
  }

  FocusScope.of(context).unfocus();

  setState(() {
    _processingDonation = true;
  });

  try {
    final paymentIntentId =
        await StripePaymentService.instance
            .makeDonation(
      amount: amount,
    );

    if (!mounted) return;

    if (paymentIntentId == null) {
      return;
    }

    _showSuccessMessage(
      'Thank you! Your donation was successful.',
    );

    _donationController.clear();

    setState(() {
      _selectedDonationIndex = 2;
    });
  } catch (error, stackTrace) {
    debugPrint('DONATION ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    _showErrorMessage(
      error
          .toString()
          .replaceFirst('Exception: ', ''),
    );
  } finally {
    if (mounted) {
      setState(() {
        _processingDonation = false;
      });
    }
  }
}

@override
void dispose() {
  _donationController.dispose();
  super.dispose();
}

  int _asInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  Future<void> _loadFaqData() async {
    try {
      final results = await Future.wait([
        _faqService.fetchFaqCategories(),
        _faqService.fetchFaqs(),
      ]);

      if (!mounted) return;

      final categories = List<Map<String, dynamic>>.from(results[0]);
      final faqs = List<Map<String, dynamic>>.from(results[1]);

      categories.sort(
        (a, b) => _asInt(a['position']).compareTo(_asInt(b['position'])),
      );
      faqs.sort(
        (a, b) => _asInt(a['position']).compareTo(_asInt(b['position'])),
      );

      setState(() {
        _categories = categories;
        _allFaqs = faqs;
        _loadingFaqs = false;

        if (_categories.isNotEmpty) {
          _selectedCategoryId = _asInt(_categories.first['id']);
          _filterFaqs(_selectedCategoryId!, updateState: false);
        } else {
          _displayedFaqs = List<Map<String, dynamic>>.from(_allFaqs);
        }
      });
    } catch (error, stackTrace) {
      debugPrint('FAQ PAGE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() => _loadingFaqs = false);
    }
  }

  void _filterFaqs(int categoryId, {bool updateState = true}) {
    final filtered = _allFaqs.where((faq) {
      return _asInt(faq['category_id']) == categoryId;
    }).toList();

    if (updateState) {
      setState(() {
        _selectedCategoryId = categoryId;
        _displayedFaqs = filtered;
      });
    } else {
      _displayedFaqs = filtered;
    }
  }

  IconData _categoryIcon(String slug) {
    switch (slug) {
      case 'general-questions':
        return Icons.logout;
      case 'login-issues':
        return Icons.help_outline;
      case 'online-puja':
        return Icons.auto_awesome;
      case 'astrology-services':
        return Icons.star_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // App Bar Header
      appBar: CustomTopNavBar(
        title: 'Mero Guru',
        style: NavBarStyle.BrandedLight,
        showBack: true,
        showCart: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            const Text(
              'Support/ Help',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA6400),
              ),
            ),
            const SizedBox(height: 16),

            // Service Navigation Button Grid
            if (_loadingFaqs)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final categoryId = _asInt(category['id']);
                  final slug = category['slug']?.toString() ?? '';
                  final isHighlighted = _selectedCategoryId == categoryId;

                  return InkWell(
                    onTap: () => _filterFaqs(categoryId),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? const Color(0xFFA13E00)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHighlighted
                              ? Colors.transparent
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcon(slug),
                            color: isHighlighted
                                ? Colors.white
                                : const Color(0xFFA13E00),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category['title']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isHighlighted
                                    ? Colors.white
                                    : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Accordion FAQs Section
            if (!_loadingFaqs && _displayedFaqs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No frequently asked questions found in this category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              ...List.generate(_displayedFaqs.length, (index) {
                final faq = _displayedFaqs[index];
                return _buildFaqItem(
                  title: faq['question']?.toString() ?? '',
                  content: faq['answer']?.toString() ?? '',
                  initiallyExpanded: index == 0,
                );
              }),

            const SizedBox(height: 20),

            // Donate Card Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DONATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA13E00),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your donation helps Mero Guru research and spread knowledge about auspicious dates, rituals, festivals, and their deep religious and cultural significance—empowering communities and keeping our heritage alive for future generations.',
                    style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // Preset Amount Selection Buttons
                 Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.shade200,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      const Text(
        'DONATE',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        'Support Mero Guru by making a donation.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),

      const SizedBox(height: 20),

      Row(
        children: List.generate(
          _donationAmounts.length,
          (index) {
            final amount =
                _donationAmounts[index];

            final selected =
                _selectedDonationIndex ==
                    index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index <
                          _donationAmounts
                                  .length -
                              1
                      ? 8
                      : 0,
                ),
                child: OutlinedButton(
                  onPressed:
                      _processingDonation
                          ? null
                          : () {
                              setState(() {
                                _selectedDonationIndex =
                                    index;

                                _donationController
                                    .clear();
                              });
                            },
                  style:
                      OutlinedButton.styleFrom(
                    backgroundColor: selected
                        ? const Color(
                            0xFFFF5A00,
                          )
                        : Colors.white,
                    foregroundColor: selected
                        ? Colors.white
                        : const Color(
                            0xFFFF5A00,
                          ),
                    side: const BorderSide(
                      color: Color(
                        0xFFFF5A00,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: _donationController,
        enabled: !_processingDonation,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        textInputAction:
            TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(
              r'^\d{0,6}(\.\d{0,2})?$',
            ),
          ),
        ],
        onChanged: (value) {
          final hasCustomAmount =
              value.trim().isNotEmpty;

          if (hasCustomAmount &&
              _selectedDonationIndex != -1) {
            setState(() {
              _selectedDonationIndex = -1;
            });
          }
        },
        onSubmitted: (_) {
          if (!_processingDonation) {
            _makeDonation();
          }
        },
        decoration: InputDecoration(
          labelText: 'Custom amount',
          hintText: 'Enter amount',
          prefixText: '\$ ',
          suffixText: 'AUD',
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFFF5A00),
              width: 1.5,
            ),
          ),
        ),
      ),

      const SizedBox(height: 8),

      Text(
        _selectedDonationIndex >= 0
            ? 'Selected: \$${_donationAmounts[_selectedDonationIndex].toStringAsFixed(2)} AUD'
            : 'Custom donation amount',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),

      const SizedBox(height: 18),

      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _processingDonation
              ? null
              : _makeDonation,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFFF5A00),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFFFFA675),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
          child: _processingDonation
              ? const SizedBox(
                  width: 23,
                  height: 23,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'DONATE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
        ),
      ),
    ],
  ),
)

                  // Custom Amount Input
                  

                  // Donate Button
          
                ],
              ),
            ),

            const SizedBox(height: 24),

            // "Ask Us" Contact Form Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ask Us',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  _buildFormLabel('NAME*'),
                  _buildTextField('Your Name'),
                  const SizedBox(height: 12),

                  _buildFormLabel('EMAIL*'),
                  _buildTextField('your@email.com'),
                  const SizedBox(height: 12),

                  _buildFormLabel('PHONE*'),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _selectedCountryCode,
                            items: const [
                              DropdownMenuItem(value: '+977', child: Text('+977', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: '+61', child: Text('+61', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCountryCode = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField('Phone Number')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildFormLabel('QUERY*'),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'How can we help?',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bottom "Still have questions?" Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFA6400),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble, color: Colors.black87, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Still have questions?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'CONTACT US',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactAction(Icons.phone_outlined, 'CALL SUPPORT'),
                      const SizedBox(width: 24),
                      _buildContactAction(Icons.email_outlined, 'EMAIL US'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // FAQ Expandable Container Item
  Widget _buildFaqItem({
    required String title,
    required String content,
    required bool initiallyExpanded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: const Color(0xFFA13E00),
          collapsedIconColor: const Color(0xFFA13E00),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Html(
                  data: content,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: Colors.black54,
                      fontSize: FontSize(12),
                      lineHeight: const LineHeight(1.4),
                    ),
                    'p': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    'span': Style(
                      color: Colors.black54,
                      fontSize: FontSize(12),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Preset Donation Button Widget
  Widget _buildDonationButton(int index, String label) {
    final isSelected = _selectedDonationIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedDonationIndex = index),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA13E00) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildContactAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFA13E00), size: 18),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}