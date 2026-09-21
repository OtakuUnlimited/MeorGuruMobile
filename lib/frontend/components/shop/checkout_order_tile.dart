import 'package:flutter/material.dart';
import '../../../constants.dart';

class CheckoutOrderTile extends StatelessWidget {
  final String englishName;
  final String localName;
  final String originalPriceString;
  final String? discountedPriceString;
  final String imageUrl;
  final int quantity;
  final VoidCallback? onRemoveItem;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CheckoutOrderTile({
    super.key,
    required this.englishName,
    required this.localName,
    required this.originalPriceString,
    this.discountedPriceString,
    required this.imageUrl,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnglishName =
        englishName.trim().isNotEmpty;

    final primaryName = hasEnglishName
        ? englishName
        : localName;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 135,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image.network(
                    imageUrl,
                    width: 105,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            _imagePlaceholder(),
                  ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // English name at the top
                Text(
                  primaryName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textDark,
                  ),
                ),

                // Nepali/local name below
                if (hasEnglishName &&
                    localName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    localName,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                if (discountedPriceString !=
                    null) ...[
                  Text(
                    originalPriceString,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                      decoration:
                          TextDecoration
                              .lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    discountedPriceString!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.orangeMain,
                    ),
                  ),
                ] else
                  Text(
                    originalPriceString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.orangeMain,
                    ),
                  ),

                const SizedBox(height: 7),

                Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed:
                            quantity <= 1 ? null : onDecrement,
                        icon: const Icon(
                          Icons.remove,
                          size: 21,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 32,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onIncrement,
                        icon: const Icon(
                          Icons.add,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onRemoveItem,
              style: IconButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFFEBEE),
                foregroundColor:
                    const Color(0xFFC62828),
              ),
              icon: const Icon(
                Icons.delete_outline,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 105,
      height: 105,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 34,
        color: Colors.grey,
      ),
    );
  }
}