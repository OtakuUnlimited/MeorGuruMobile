import 'package:flutter/material.dart';

import 'shop_widgets.dart';

class PopularItemsCarousel
    extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  final Function(Map<String, dynamic>)?
      onItemTap;

      double? _getDiscountPercentage(
  Map<String, dynamic> item,
) {
  final value = item['discount_percentage'];

  if (value == null) {
    return null;
  }

  final percentage =
      double.tryParse(value.toString());

  if (percentage == null || percentage <= 0) {
    return null;
  }

  return percentage;
}

double? _getDiscountAmount(
  Map<String, dynamic> item,
) {
  final value = item['discount_amount'];

  if (value == null) {
    return null;
  }

  final amount =
      double.tryParse(value.toString());

  if (amount == null || amount <= 0) {
    return null;
  }

  return amount;
}

  const PopularItemsCarousel({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No popular products found',
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          final rawImages = item['images'];

          final image =
              rawImages is List &&
                      rawImages.isNotEmpty
                  ? rawImages.first.toString()
                  : '';

          final originalPrice =
              double.tryParse(
                    item['price']
                            ?.toString() ??
                        '0',
                  ) ??
                  0;

          final discountedPrice =
              double.tryParse(
            item['discounted_price']
                    ?.toString() ??
                '',
          );

          final hasDiscount =
              discountedPrice != null &&
              discountedPrice <
                  originalPrice;

          final rawStock =
              item['in_stock'];

          final inStock =
              rawStock == true ||
              rawStock == 1 ||
              rawStock?.toString() == '1';

          return GestureDetector(
            onTap: () =>
                onItemTap?.call(item),
            child: ProductCard(
              width: 164,

              title: item['name']?.toString() ?? '',

              englishName:
                  item['english_name']?.toString(),

              priceString:
                  '\$${originalPrice.toStringAsFixed(2)} AUD',

              discountedPriceString:
                  hasDiscount
                      ? '\$${discountedPrice!.toStringAsFixed(2)} AUD'
                      : null,

              imagePathUrl: image,

              inStock: inStock,

              discountPercentage:
                  _getDiscountPercentage(item),

              discountAmount:
                  _getDiscountAmount(item),
            )
          );
        },
      ),
    );
  }
}