import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../../routes/app_routes.dart';


class CategoryGridView extends StatefulWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final bool shrinkWrap;
  final bool isCompact;
  final ScrollPhysics? physics;
  final void Function(Map<String, dynamic> category)? onCategoryTap;

  const CategoryGridView({
    Key? key,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.85,
    this.shrinkWrap = true,
    this.isCompact = false,
    this.physics = const NeverScrollableScrollPhysics(),
    this.onCategoryTap,
  }) : super(key: key);

  @override
  State<CategoryGridView> createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
  final ContentService _contentService = ContentService();

  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    // 1. Load cached categories immediately
    categories =
        await _contentService.getCachedCategories();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    // 2. Refresh from backend
    try {
      final freshCategories =
          await _contentService.refreshCategories();

      if (!mounted) return;

      setState(() {
        categories = freshCategories;
      });
    } catch (e) {
      debugPrint("Category refresh failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isCompact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),

      padding: widget.isCompact
          ? EdgeInsets.zero
          : const EdgeInsets.all(18),

      decoration: widget.isCompact
          ? null
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppColors.borderGray.withOpacity(0.4),
                width: 0.8,
              ),
            ),

      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.orangeMain,
                ),
              ),
            )
          : categories.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Unable to load services at this time.",
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: widget.shrinkWrap,
                  physics: widget.physics,
                  itemCount: categories.length > 20
                  ? 20
                  : categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.crossAxisCount,
                    crossAxisSpacing: widget.isCompact ? 10 : 14,
                    mainAxisSpacing: widget.isCompact ? 12 : 18,
                    childAspectRatio: widget.childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index] as Map<String, dynamic>;
                    return _buildCategoryItem(context, category);
                  },
                ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final String imageUrl = category['image'] ?? '';
    final String title = category['title'] ?? '';
    final String slug = category['slug'] ?? '';

    return GestureDetector(
      onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.services,
            arguments: {
              'slug': slug,
              'title': title,
            },
          );
      },

      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 4 : 6,
          vertical: widget.isCompact ? 6 : 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: AppColors.borderGray.withOpacity(0.3),
            width: 0.6,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(widget.isCompact ? 8 : 12),

              height: widget.isCompact ? 52 : 62,
              width: widget.isCompact ? 52 : 62,

              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,

                border: Border.all(
                  color: AppColors.orangeMain.withOpacity(0.4),
                  width: 1,
                ),
              ),

              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.category,
                          color: AppColors.orangeMain,
                          size: 22,
                        );
                      },
                    )
                  : const Icon(
                      Icons.category,
                      color: AppColors.orangeMain,
                      size: 22,
                    ),
            ),

            SizedBox(height: widget.isCompact ? 6 : 10),

            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: widget.isCompact ? 10 : 11.5,
                  color: Colors.black87,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),

                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}