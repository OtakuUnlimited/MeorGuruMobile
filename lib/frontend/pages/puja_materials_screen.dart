import 'package:flutter/material.dart';

class PujaMaterialsScreen extends StatefulWidget {
  const PujaMaterialsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _PujaMaterialsScreenState();
}

class _PujaMaterialsScreenState extends State {
  String? _selectedPuja;

  // Puja List from the image[cite: 15]
  final List<String> _popularPujas = const [
    'जन्मोत्सव पूजा',
    'अन्नप्राशन पूजा',
    'व्रतबन्ध पूजा',
    'नामाकरण (नवारन) पूजा',
    'ग्रहशान्ति पूजा',
    'सत्यनारायण पूजा',
    'ग्रहशान्ति सहित घर (रुद्री, हवन, वास्तु) पूजा',
    'सत्यनारायण सहित घर (रुद्री, हवन, वास्तु) पूजा',
    'घर (रुद्री, हवन, वास्तु) पूजा',
    'लाखबत्ती सहित घर (रुद्री, हवन, वास्तु) पूजा',
    'गृह प्रवेश पूजा',
    'गुन्यूचोली पूजा',
    'विवाह पूजा',
    'व्यवसाय आरम्भ पूजा',
    'शिलान्यास (भूमि) पूजा',
    'पार्वण (महालय) श्राद्ध पूजा',
    'एकपार्वण (तिथि, महालय) श्राद्ध पूजा',
    'स्वयम्बर पूजा',
    'बेल विवाह पूजा',
    'कृत्याकर्म (मृत्यु संस्कार) पूजा',
    'चूडाकर्म (छवर) पूजा',
    'रूद्र अभिषेक पूजा',
    'तुलसी विवाह पूजा',
    'एकोद्दिष्ट (तिथि) श्राद्ध',
  ];

  final List<Map<String, String>> _steps = const [
    {
      'step': '01',
      'title': 'Select the Puja',
    },
    {
      'step': '02',
      'title': 'Understand the Importance of the Puja',
    },
    {
      'step': '03',
      'title': 'Find the Puja Materials',
    },
    {
      'step': '04',
      'title': 'Download the Puja Materials for Your Convenience',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFA6400),
              ),
              child: const Icon(Icons.brightness_7, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'MeroGuru',
              style: TextStyle(
                color: Color(0xFFFA6400),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Date and Location Sub-header Banner[cite: 15]
            const SizedBox(height: 28),

            // Popular Puja In Australia Grid Header[cite: 15]
            const Text(
              'Popular Puja In Australia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA6400),
              ),
            ),
            const SizedBox(height: 16),

            // 2-Column Grid for Mobile Buttons[cite: 15]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _popularPujas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107), // Amber yellow shade from desktop mockup[cite: 15]
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.brightness_6, size: 12, color: Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _popularPujas[index],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Select Puja Dropdown Container Card[cite: 15]
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select the Puja from the Below to find the List',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFA6400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select the Ritual:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  
                  // Dropdown Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _selectedPuja,
                        hint: const Text('Dropdown List of Puja Here', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        isExpanded: true,
                        items: _popularPujas.map((String puja) {
                          return DropdownMenuItem(
                            value: puja,
                            child: Text(puja, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPuja = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA6400),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Find Puja Materials',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Red Mobile Footer Block[cite: 15]
          ],
        ),
      ),
    );
  }

  // Dark Red Footer Component matching previously generated pages
  
}