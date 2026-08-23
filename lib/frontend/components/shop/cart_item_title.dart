import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'shop_widgets.dart';

class CartItemTile extends StatelessWidget {
  final String name;
  final String priceString;
  final String imageUrl;
  final int quantity;
  final bool isSelected;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CartItemTile({
    Key? key,
    required this.name,
    required this.priceString,
    required this.imageUrl,
    required this.quantity,
    required this.isSelected,
    required this.onCheckboxChanged,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12,
      ),
      child: Row(
        children: [
          Checkbox(
            activeColor: AppColors.orangeMain,
            value: isSelected,
            onChanged: onCheckboxChanged,
          ),

          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey.shade200,
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 6),

                InlineQtyCounter(
                  currentCount: quantity,

                  // Nullable callback -> safe VoidCallback
                  onAdd: onIncrement ?? () {},

                  onRemove: onDecrement ?? () {},

                  compactStyle: true,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            priceString,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}