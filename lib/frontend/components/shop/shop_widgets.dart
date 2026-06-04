import 'package:flutter/material.dart';
import '../../../constants.dart';

/// Product Grid/List Card used in Shop layout grids and Detail section related lists
class ProductCard extends StatelessWidget {
  final double? width;
  final String title;
  final String priceString;
  final String imagePathUrl;

  const ProductCard({
    Key? key,
    this.width,
    required this.title,
    required this.priceString,
    required this.imagePathUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: width != null ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imagePathUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade100),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  priceString,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.orangeMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Horizontal Categorization pill chips used for filtering context
class CategoryPillChip extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryPillChip({
    Key? key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.orangeMain.withOpacity(0.3),
          ),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.orangeMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Inline Quantity Modifier Incrementer Controls (used inside Cart & Product Details)
class InlineQtyCounter extends StatelessWidget {
  final int currentCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool compactStyle;

  const InlineQtyCounter({
    Key? key,
    required this.currentCount,
    required this.onAdd,
    required this.onRemove,
    this.compactStyle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compactStyle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onRemove,
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$currentCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: onAdd,
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: onRemove),
              Text('$currentCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          )
        ],
      ),
    );
  }
}

/// Structured Standard Input Text Field Form Controls for Checkout screens
class CheckoutInputField extends StatelessWidget {
  final String labelTitle;
  final String formPlaceholder;
  final TextEditingController? fieldController;

  const CheckoutInputField({
    Key? key,
    required this.labelTitle,
    required this.formPlaceholder,
    this.fieldController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          TextField(
            controller: fieldController,
            decoration: InputDecoration(
              hintText: formPlaceholder,
              hintStyle: const TextStyle(color: Colors.black26),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.orangeMain)),
            ),
          ),
        ],
      ),
    );
  }
}