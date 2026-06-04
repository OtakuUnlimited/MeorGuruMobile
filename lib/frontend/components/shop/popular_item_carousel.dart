import 'package:flutter/material.dart';
import 'shop_widgets.dart'; // Imports the ProductCard architecture

class PopularItemsCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>)? onItemTap;

  const PopularItemsCarousel({
    Key? key,
    required this.items,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap?.call(item),
            child: ProductCard(
              width: 164,
              title: item['title'] ?? '',
              priceString: item['price'] ?? '',
              imagePathUrl: item['image'] ?? 'https://picsum.photos/200',
            ),
          );
        },
      ),
    );
  }
}