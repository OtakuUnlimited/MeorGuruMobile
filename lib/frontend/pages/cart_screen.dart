import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/cart_item_title.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Stateful mock representing live interaction matching layout designs
  final List<Map<String, dynamic>> _cartItems = [
    {'id': 1, 'name': 'Item 1', 'price': 999, 'qty': 2, 'selected': true, 'img': 'https://picsum.photos/id/20/150/150'},
    {'id': 2, 'name': 'Item 2', 'price': 450, 'qty': 1, 'selected': false, 'img': 'https://picsum.photos/id/21/150/150'},
    {'id': 3, 'name': 'Item 3', 'price': 1200, 'qty': 1, 'selected': false, 'img': 'https://picsum.photos/id/22/150/150'},
    {'id': 4, 'name': 'Item 4', 'price': 150, 'qty': 3, 'selected': false, 'img': 'https://picsum.photos/id/23/150/150'},
  ];

  // Helper properties to calculate state selection updates
  bool get _isAllSelected => _cartItems.every((item) => item['selected'] == true);

  int get _calculateSubtotal {
    return _cartItems
        .where((item) => item['selected'] == true)
        .fold<int>(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
  }

  void _toggleSelectAll(bool? checked) {
    setState(() {
      for (var item in _cartItems) {
        item['selected'] = checked ?? false;
      }
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      _cartItems.removeWhere((item) => item['selected'] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavBar(
        title: 'Your Cart',
        style: NavBarStyle.BrandedLight,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.orangeMain, size: 28),
            onPressed: _deleteSelectedItems,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Text(
              'Your Cart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return CartItemTile(
                        name: item['name'],
                        priceString: '${item['price']}AUD',
                        imageUrl: item['img'],
                        quantity: item['qty'],
                        isSelected: item['selected'],
                        onCheckboxChanged: (val) {
                          setState(() => item['selected'] = val ?? false);
                        },
                        onIncrement: () {
                          setState(() => item['qty']++);
                        },
                        onDecrement: () {
                          setState(() {
                            if (item['qty'] > 1) item['qty']--;
                          });
                        },
                      );
                    },
                  ),
          ),
          
          // Total Computations Bottom Summary Drawer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: AppColors.orangeMain,
                            value: _isAllSelected,
                            onChanged: _toggleSelectAll,
                          ),
                          const Text(
                            'All',
                            style: TextStyle(fontSize: 16, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            '${_calculateSubtotal}AUD',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828), // Deep Red matching theme buttons
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: _calculateSubtotal == 0 
                          ? null 
                          : () {
                              // Direct navigation path execution logic to Checkout
                            },
                      icon: const Icon(Icons.wallet, color: Colors.white),
                      label: const Text(
                        'Check Out',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}