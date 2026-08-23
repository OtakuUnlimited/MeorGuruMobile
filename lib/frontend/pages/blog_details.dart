import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';

class BlogDetailScreen extends StatefulWidget {
  final String slug;

  const BlogDetailScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  State<BlogDetailScreen> createState() =>
      _MobileBlogDetailScreenState();
}

class _MobileBlogDetailScreenState extends State<BlogDetailScreen> {
  final ContentService _contentService = ContentService();

  Map<String, dynamic>? _blog;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlog();
  }

  Future<void> _loadBlog() async {
    try {
      final blog = await _contentService.fetchBlogDetails(widget.slug);

      if (!mounted) return;

      setState(() {
        _blog = blog;
        _loading = false;
      });
    } catch (e) {
      debugPrint('BLOG DETAIL ERROR: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Custom MeroGuru navigation bar
      appBar: const CustomTopNavBar(
        title: 'Blog',
        style: NavBarStyle.BrandedLight,
        showBack: true,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? _buildError()
              : _blog == null
                  ? const Center(
                      child: Text('Blog not found'),
                    )
                  : _buildBlog(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load blog',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });

                _loadBlog();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlog() {
    final blog = _blog!;

    final String title =
        blog['title']?.toString() ?? 'Untitled Blog';

    final String shortDescription =
        blog['short_description']?.toString() ?? '';

    final String description =
        blog['description']?.toString() ?? '';

    final String image =
        blog['image']?.toString() ?? '';

    /*
     * Depending on your API, these may have different names.
     * We check several possible fields so the UI doesn't break.
     */
    final String author =
        blog['author']?.toString() ??
        blog['writer']?.toString() ??
        blog['author_name']?.toString() ??
        blog['user']?['name']?.toString() ??
        'MeroGuru';

    final String date =
        blog['date']?.toString() ??
        blog['created_at']?.toString() ??
        blog['published_at']?.toString() ??
        '';

    final List<dynamic> keywords =
        blog['keyword'] is List ? blog['keyword'] : [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // BLOG TITLE
            // ------------------------------------------------
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------
            // AUTHOR + DATE + TAGS
            // ------------------------------------------------
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                // Writer
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Date
                if (date.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                // Tags
                if (keywords.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.label_outline,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        keywords
                            .map((e) => e.toString())
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------
            // BLOG IMAGE
            // ------------------------------------------------
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // SHORT DESCRIPTION
            // ------------------------------------------------
            if (shortDescription.isNotEmpty)
              Text(
                shortDescription,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),

            // ------------------------------------------------
            // FULL DESCRIPTION
            // ------------------------------------------------
            if (description.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildArticleContent(description),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(String content) {
    final cleanedContent = content
        .replaceAll(
          RegExp(r'<br\s*/?>', caseSensitive: false),
          '\n',
        )
        .replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        )
        .trim();

    final paragraphs = cleanedContent
        .split(RegExp(r'\n+'))
        .where(
          (text) => text.trim().isNotEmpty,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            paragraph.trim(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}