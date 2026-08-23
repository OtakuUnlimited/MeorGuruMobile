import 'package:flutter/material.dart';
import 'shop_widgets.dart';

class PopularItemsCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>)? onItemTap;

  const PopularItemsCarousel({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          String image = '';

          if (item['images'] != null &&
              item['images'] is List &&
              (item['images'] as List).isNotEmpty) {
            image = item['images'][0].toString();
          }

          return GestureDetector(
            onTap: () => onItemTap?.call(item),
            child: ProductCard(
              width: 164,
              title: item['name'] ?? '',
              priceString:
                  '\$${item['discounted_price'] ?? item['price']}',
              imagePathUrl: image,
            ),
          );
        },
      ),
    );
  }
}