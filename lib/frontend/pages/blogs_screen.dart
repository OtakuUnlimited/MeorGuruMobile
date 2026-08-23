import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import '../../routes/app_routes.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final ContentService _contentService = ContentService();

  // ============================================================
  // PAGINATION
  // ============================================================

  int _currentPage = 1;

  static const int _blogsPerPage = 5;

  // ============================================================
  // STATE
  // ============================================================

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _blogPosts = [];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  // ============================================================
  // LOAD BLOGS
  // ============================================================

  Future<void> _loadBlogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final blogs = await _contentService.getBlogs();

      if (!mounted) return;

      setState(() {
        _blogPosts = blogs;
        _currentPage = 1;
        _loading = false;
      });
    } catch (e) {
      debugPrint('BLOG LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load blogs.';
      });
    }
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String _getImageUrl(dynamic image) {
    if (image == null || image.toString().isEmpty) {
      return '';
    }

    String url = image.toString();

    // Android emulator
    if (url.contains('127.0.0.1:8000')) {
      url = url.replaceFirst(
        '127.0.0.1:8000',
        '10.0.2.2:8000',
      );
    }

    return url;
  }

  // ============================================================
  // TOTAL PAGES
  // ============================================================

  int get _totalPages {
    if (_blogPosts.isEmpty) {
      return 1;
    }

    return (_blogPosts.length / _blogsPerPage).ceil();
  }

  // ============================================================
  // BLOGS FOR CURRENT PAGE
  // ============================================================

  List<Map<String, dynamic>> get _currentPageBlogs {
    final startIndex = (_currentPage - 1) * _blogsPerPage;

    if (startIndex >= _blogPosts.length) {
      return [];
    }

    final endIndex =
        (startIndex + _blogsPerPage > _blogPosts.length)
            ? _blogPosts.length
            : startIndex + _blogsPerPage;

    return _blogPosts.sublist(
      startIndex,
      endIndex,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),

      // ========================================================
      // CUSTOM TOP NAVIGATION
      // ========================================================

      appBar: const CustomTopNavBar(
        title: 'MeroGuru Blogs',
        style: NavBarStyle.BrandedLight,
        showBack: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadBlogs,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            16,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'MeroGuru Blogs',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFA6400),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Dive deeper into the essence of Hindu way by reading the articles below',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // BLOG LIST
                        // ==================================================

                        if (_blogPosts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 60,
                              bottom: 60,
                            ),
                            child: Text(
                              'No blogs available.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            itemCount:
                                _currentPageBlogs.length,
                            itemBuilder:
                                (context, index) {
                              final post =
                                  _currentPageBlogs[index];

                              return _buildSingleBlogCard(
                                post,
                              );
                            },
                          ),

                        // ==================================================
                        // PAGINATION
                        // ==================================================

                        if (_blogPosts.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildPagination(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar:
          const CustomBottomNavBar(
        activeIndex: 3,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          Text(
            _error ?? 'Something went wrong.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loadBlogs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMain,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BLOG CARD
  // ============================================================

  Widget _buildSingleBlogCard(
    Map<String, dynamic> post,
  ) {
    final title =
        post['title']?.toString() ?? '';

    final description =
        post['short_description']?.toString() ?? '';

    final image =
        _getImageUrl(post['image']);

    final slug =
        post['slug']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================
          // BLOG IMAGE
          // ==================================================

          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: image.isEmpty
                ? Container(
                    height: 180,
                    width: double.infinity,
                    color:
                        Colors.grey.shade200,
                    child: const Icon(
                      Icons
                          .image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    loadingBuilder:
                        (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress ==
                          null) {
                        return child;
                      }

                      return Container(
                        height: 180,
                        width: double.infinity,
                        color:
                            Colors.grey.shade100,
                        child:
                            const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    },

                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      debugPrint(
                        'BLOG IMAGE ERROR: $error',
                      );

                      return Container(
                        height: 180,
                        width: double.infinity,
                        color:
                            Colors.grey.shade200,
                        child:
                            const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          ),

          // ==================================================
          // BLOG CONTENT
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.black87,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // DESCRIPTION
                Text(
                  description,
                  maxLines: 5,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // READ MORE
                // ==================================================

                GestureDetector(
                  onTap: slug.isEmpty
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.blogDetails,
                            arguments: slug,
                          );
                        },
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: const [
                      Text(
                        'READ MORE',
                        style:
                            TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFFFA6400),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color:
                            Color(0xFFFA6400),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Divider(
                  height: 1,
                  color:
                      Color(0xFFEEEEEE),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // BLOG FOOTER
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'MeroGuru',
                      style:
                          TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey,
                      ),
                    ),
                    Text(
                      '18 Aug 2026',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        // ========================================================
        // PREVIOUS
        // ========================================================

        TextButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });

                  _scrollToTop();
                }
              : null,
          child: const Text(
            '< Previous',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(width: 4),

        // ========================================================
        // PAGE NUMBERS
        // ========================================================

        for (
          int i = 1;
          i <= _totalPages;
          i++
        )
          InkWell(
            onTap: () {
              setState(() {
                _currentPage = i;
              });

              _scrollToTop();
            },
            borderRadius:
                BorderRadius.circular(4),
            child: Container(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              width: 30,
              height: 30,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color:
                    _currentPage == i
                        ? const Color(
                            0xFFFA6400,
                          )
                        : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(4),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  color:
                      _currentPage == i
                          ? Colors.white
                          : Colors.black87,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

        const SizedBox(width: 4),

        // ========================================================
        // NEXT
        // ========================================================

        TextButton(
          onPressed:
              _currentPage < _totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });

                      _scrollToTop();
                    }
                  : null,
          child: const Text(
            'Next >',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCROLL TO TOP WHEN PAGE CHANGES
  // ============================================================

  void _scrollToTop() {
    // Since the page is using a SingleChildScrollView,
    // this schedules the scroll after the rebuild.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;

        Scrollable.ensureVisible(
          context,
          duration:
              const Duration(milliseconds: 300),
        );
      },
    );
  }
}