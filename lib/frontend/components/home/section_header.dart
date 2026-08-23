import 'package:flutter/material.dart';
import '../../../constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  // True when the header is placed on the orange background section
  final bool onOrangeBackground;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.onOrangeBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TITLE
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,

                // Keep normal title dark.
                // Use white title when inside orange section.
                color: onOrangeBackground
                    ? Colors.white
                    : AppColors.textDark,
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// VIEW MORE BUTTON
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: onOrangeBackground
                    ? Colors.white
                    : const Color(0xFFB31919),

                border: Border.all(
                  color: onOrangeBackground
                      ? Colors.white
                      : const Color(0xFFB31919),
                ),

                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "View More",
                style: TextStyle(
                  color: onOrangeBackground
                      ? const Color(0xFFB31919)
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}