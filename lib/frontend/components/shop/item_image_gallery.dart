import 'package:flutter/material.dart';
import '../../../constants.dart';

class ItemImageGallery extends StatefulWidget {
  final List<String> images;

  const ItemImageGallery({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  State<ItemImageGallery> createState() => _ItemImageGalleryState();
}

class _ItemImageGalleryState extends State<ItemImageGallery> {
  int _activeImageIndex = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousImage() {
  final index = _activeImageIndex > 0
      ? _activeImageIndex - 1
      : widget.images.length - 1;

  _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

void _nextImage() {
  final index = _activeImageIndex < widget.images.length - 1
      ? _activeImageIndex + 1
      : 0;

  _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Main Window Display Display Frame Box
        Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _activeImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Left Chevron Toggle
            Positioned(
              left: 12,
              top: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _previousImage,
                ),
              ),
            ),
            // Right Chevron Toggle
            Positioned(
              right: 12,
              top: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _nextImage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Thumbnail Selection Strip
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final bool isActive = index == _activeImageIndex;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? AppColors.orangeMain : Colors.grey.shade300, 
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}