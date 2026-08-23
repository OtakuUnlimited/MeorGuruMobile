
import 'package:flutter/material.dart';
import '../../../backend/services/content_services.dart';
import '../../../routes/app_routes.dart';

class BlogSection extends StatelessWidget {
  const BlogSection({super.key});

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ContentService().fetchBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Unable to load blogs.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No blogs available.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          );
        }

        final blogs = snapshot.data!;

        return Column(
          children: blogs.map<Widget>((blog) {
            final title =
                blog['title']?.toString() ?? '';

            final shortDescription =
                blog['short_description']?.toString() ?? '';

            final image =
                _getImageUrl(blog['image']);

            final slug =
                blog['slug']?.toString() ?? '';

            return GestureDetector(
              onTap: slug.isEmpty
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.blogDetails,
                        arguments: slug,
                      );
                    },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
                        top: Radius.circular(18),
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
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  height: 180,
                                  width: double.infinity,
                                  color:
                                      Colors.grey.shade200,
                                  child:
                                      const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color:
                                        Colors.grey,
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
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // SHORT DESCRIPTION
                          Text(
                            shortDescription,
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // READ MORE
                          Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: const [
                              Text(
                                'READ MORE',
                                style: TextStyle(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}