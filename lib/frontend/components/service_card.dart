import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String devanagariTitle;
  final String englishTitle;
  final String price;
  final String imageUrl;
  final VoidCallback onBookNow;

  const ServiceCard({
    super.key,
    required this.devanagariTitle,
    required this.englishTitle,
    required this.price,
    required this.imageUrl,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            /*
             * Flexible image area prevents vertical
             * overflow on smaller iPhones.
             */
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final size =
                        constraints.maxHeight
                            .clamp(65.0, 100.0);

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.1),
                            blurRadius: 6,
                            offset:
                                const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }

                            return Container(
                              color: Colors
                                  .grey.shade100,
                              alignment:
                                  Alignment.center,
                              child:
                                  const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color: Colors
                                  .grey.shade200,
                              alignment:
                                  Alignment.center,
                              child: const Icon(
                                Icons
                                    .image_not_supported,
                                color: Colors.grey,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 7),

            /*
             * Devanagari title
             */
            Text(
              devanagariTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC62828),
              ),
            ),

            const SizedBox(height: 3),

            /*
             * English title
             */
            Text(
              englishTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            /*
             * Price
             */
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0531A),
              ),
            ),

            const SizedBox(height: 7),

            /*
             * Responsive Book Now button
             */
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFA6400),
                  foregroundColor: Colors.white,
                  disabledForegroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  minimumSize:
                      const Size(0, 38),
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Book Now',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}