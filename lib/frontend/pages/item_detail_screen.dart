import 'package:flutter/material.dart';
import '../../constants.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../components/shop/shop_widgets.dart'; // Imports universal ProductCard and InlineQtyCounter
import '../components/shop/item_image_gallery.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({Key? key}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _itemQuantity = 1;

  // Mock assets for detail display
  final List<String> _productImages = [
    'https://picsum.photos/id/1080/400/400',
    'https://picsum.photos/id/1025/400/400',
    'https://picsum.photos/id/60/400/400',
  ];

  final List<Map<String, dynamic>> _relatedProducts = [
    {'title': 'Sukunda Brass Vase', 'price': '9999AUD', 'image': 'https://picsum.photos/id/1080/300/300'},
    {'title': 'Pooja Bell (Ghanti)', 'price': '450AUD', 'image': 'https://picsum.photos/id/1025/300/300'},
    {'title': 'Traditional Tika Set', 'price': '150AUD', 'image': 'https://picsum.photos/id/60/300/300'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopNavBar(
        title: 'Item Detail',
        style: NavBarStyle.BrandedLight,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Modular Photo Gallery Strip
                  ItemImageGallery(images: _productImages),
                  
                  // Product Specification details section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item 1',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '\$99',
                          style: TextStyle(fontSize: 24, color: AppColors.orangeMain, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        
                        // 2. Quantity Counter block out of shop_widgets file
                        InlineQtyCounter(
                          currentCount: _itemQuantity,
                          onAdd: () => setState(() => _itemQuantity++),
                          onRemove: () => setState(() { if (_itemQuantity > 1) _itemQuantity--; }),
                          compactStyle: false, // Renders full padded block mode
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Category 1',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Contains sukunda, kota, sinamu, samaya khola, karuwa, jalanyaka, Chandan khori.',
                          style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                        ),
                        
                        const Divider(height: 40, thickness: 1),
                        const Text(
                          'Related Items',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 12),
                        
                        // Horizontal matching related items reel
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _relatedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _relatedProducts[index];
                              return ProductCard(
                                width: 140,
                                title: product['title'],
                                priceString: product['price'],
                                imagePathUrl: product['image'],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // Sticky Foot-line Quick Actions panel drawer block
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      label: const Text('Add to Cart', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.wallet, color: Colors.white),
                      label: const Text('Buy Now', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
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