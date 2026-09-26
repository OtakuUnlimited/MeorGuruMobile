import 'package:flutter/material.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State {
  int _selectedDonationIndex = 2; // Default selected 50$
  String _selectedCountryCode = '+977';

  // Service grid buttons data
  final List<Map<String, dynamic>> _navigationServices = [
    {
      'title': 'Login &\nRegister',
      'icon': Icons.logout,
      'isHighlighted': true,
    },
    {
      'title': 'Help & Support',
      'icon': Icons.help_outline,
      'isHighlighted': false,
    },
    {
      'title': 'Online Puja',
      'icon': Icons.auto_awesome,
      'isHighlighted': false,
    },
    {
      'title': 'Meroguru Blog',
      'icon': Icons.article_outlined,
      'isHighlighted': false,
    },
    {
      'title': 'Event\nManagement',
      'icon': Icons.calendar_month,
      'isHighlighted': false,
    },
    {
      'title': 'Patro or\nPanchanga',
      'icon': Icons.calendar_today,
      'isHighlighted': false,
    },
    {
      'title': 'Auspicious\nDays',
      'icon': Icons.star_border,
      'isHighlighted': false,
    },
    {
      'title': 'Find A Guru',
      'icon': Icons.person_search_outlined,
      'isHighlighted': false,
    },
    {
      'title': 'Service\nProviders',
      'icon': Icons.handyman_outlined,
      'isHighlighted': false,
    },
    {
      'title': 'Puja Materials',
      'icon': Icons.inventory_2_outlined,
      'isHighlighted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // App Bar Header
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFA6400),
              ),
              child: const Icon(Icons.brightness_7, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Mero Guru',
                  style: TextStyle(
                    color: Color(0xFFFA6400),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'meroguru.com',
                  style: TextStyle(color: Colors.grey, fontSize: 8),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFA6400),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87, size: 26),
            onPressed: () {},
          ),
        ],
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _navigationServices.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemBuilder: (context, index) {
                final item = _navigationServices[index];
                final isHighlighted = item['isHighlighted'] as bool;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighlighted ? const Color(0xFFA13E00) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHighlighted ? Colors.transparent : Colors.grey.shade200,
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
                        item['icon'] as IconData,
                        color: isHighlighted ? Colors.white : const Color(0xFFA13E00),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isHighlighted ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Accordion FAQs Section
            _buildFaqItem(
              title: 'Do I need to register or log in to use Sanctuary?',
              content:
                  'While you can browse rituals and explore the community, an account is required to book personalized Puja services and maintain your spiritual journal history.',
              initiallyExpanded: true,
            ),
            _buildFaqItem(
              title: 'How do I track my scheduled Rituals?',
              content: 'You can track all upcoming and past booked rituals directly from your account profile tab under "My Bookings".',
              initiallyExpanded: false,
            ),
            _buildFaqItem(
              title: 'Are the Astrologers verified?',
              content: 'Yes, all our pandits and astrologers undergo background and certification verification processes before joining MeroGuru.',
              initiallyExpanded: false,
            ),
            _buildFaqItem(
              title: 'What payment methods are supported?',
              content: 'We accept major credit/debit cards, digital wallets, and local mobile payment portals.',
              initiallyExpanded: false,
            ),

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
                  Row(
                    children: [
                      _buildDonationButton(0, '10\$'),
                      const SizedBox(width: 8),
                      _buildDonationButton(1, '15\$'),
                      const SizedBox(width: 8),
                      _buildDonationButton(2, '50\$'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Custom Amount Input
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Donate Button
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
                        'DONATE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
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
              child: Text(
                content,
                style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
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