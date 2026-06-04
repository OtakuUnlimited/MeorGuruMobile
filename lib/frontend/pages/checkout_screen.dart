import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/shop_widgets.dart'; // Imports the corrected CheckoutInputField constructor
import '../components/shop/checkout_order_tile.dart';
import '../components/shop/checkout_summary_card.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final TextEditingController _voucherController = TextEditingController();

  // Mock list items representing products reviewed inside checkout
  final List<Map<String, dynamic>> _checkoutItems = [
    {'title': 'Item 1', 'price': '999AUD', 'qty': 2, 'img': 'https://picsum.photos/id/40/100/100'},
    {'title': 'Item 2', 'price': '450AUD', 'qty': 1, 'img': 'https://picsum.photos/id/21/100/100'},
  ];

  @override
  void dispose() {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Review Scroll Area Box Frame
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _checkoutItems.length,
                itemBuilder: (context, index) {
                  final item = _checkoutItems[index];
                  return CheckoutOrderTile(
                    title: item['title'],
                    priceString: item['price'],
                    imageUrl: item['img'],
                    quantity: item['qty'],
                    onRemoveItem: () {
                      setState(() => _checkoutItems.removeAt(index));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Personal Credentials Context Section
            const CheckoutInputField(labelTitle: 'First Name', formPlaceholder: 'John'),
            const CheckoutInputField(labelTitle: 'Last Name', formPlaceholder: 'Doe'),
            const CheckoutInputField(labelTitle: 'Email', formPlaceholder: 'youemail@example.com'),
            const CheckoutInputField(labelTitle: 'Phone No.', formPlaceholder: '+977 9860000000'),

            const SizedBox(height: 12),
            const Text(
              'Address', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            
            const CheckoutInputField(labelTitle: 'Street Address', formPlaceholder: 'Street and number'),
            const CheckoutInputField(labelTitle: 'City', formPlaceholder: 'City'),
            const CheckoutInputField(labelTitle: 'Country', formPlaceholder: 'Country'),

            const SizedBox(height: 16),

            // Voucher Entry Row Wrapper
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      hintText: 'Discount Voucher',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black26),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            // System Authentication Alert Note Row
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'You need to be logged in to redeem Discount Voucher',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Financial Breakdown Summary Component Card File
            const CheckoutSummaryCard(
              subtotal: '2000AUD',
              discount: '-1000AUD',
              deliveryFee: '50.00AUD',
              tax: '50.00AUD',
              total: '1850AUD',
            ),

            const SizedBox(height: 30),

            // Main Primary Call to Action Processing Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Core Red accent button color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: const Icon(Icons.wallet, color: Colors.white),
                label: const Text(
                  'Proceed to Pay',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}