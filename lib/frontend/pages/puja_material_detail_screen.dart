import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_html/flutter_html.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../constants.dart';


import '../../backend/services/content_services.dart';

class PujaMaterialDetailScreen extends StatefulWidget {
  final String slug;

  const PujaMaterialDetailScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  State<PujaMaterialDetailScreen> createState() =>
      _PujaMaterialDetailScreenState();
}

class _PujaMaterialDetailScreenState
    extends State<PujaMaterialDetailScreen> {
  final ContentService _contentService = ContentService();

  Map<String, dynamic>? _puja;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPujaDetails();
  }

  Future<void> _loadPujaDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result =
          await _contentService.fetchPujaMaterialDetails(
        widget.slug,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isLoading = false;
          _error = 'Puja material not found.';
        });

        return;
      }

      setState(() {
        _puja = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PUJA DETAIL SCREEN ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: CustomTopNavBar(
        title: 'Mero Guru',
        style: NavBarStyle.BrandedLight,
        showBack: true,
        showCart: true,
      ),

      body: _buildBody(),
      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 2,
      ),
      
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFA6400),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.grey,
              ),

              const SizedBox(height: 12),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loadPujaDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA6400),
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
        ),
      );
    }

    if (_puja == null) {
      return const Center(
        child: Text(
          'Puja material not found.',
        ),
      );
    }

    return _buildPujaDetails();
  }

  Widget _buildPujaDetails() {
    final title = _puja!['title']?.toString() ?? '';

    final subtitle =
        _puja!['sub_title']?.toString() ?? '';

    final imageUrl =
        _puja!['image']?.toString() ?? '';

    final introduction =
        _puja!['puja_introduction']?.toString() ?? '';

    final importance =
        _puja!['puja_importance']?.toString() ?? '';

    final materials =
        _puja!['puja_material_list'] is List
            ? List<dynamic>.from(
                _puja!['puja_material_list'],
              )
            : <dynamic>[];

    final pdfUrl =
        _puja!['puja_file']?.toString() ?? '';

    return RefreshIndicator(
      onRefresh: _loadPujaDetails,
      color: const Color(0xFFFA6400),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderImage(imageUrl),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.orangeMain,
            ),
          ),

          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 24),

          if (introduction.isNotEmpty)
            _buildSection(
              title: 'Introduction',
              child: Text(
                introduction,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.6,
                ),
              ),
            ),

          if (importance.isNotEmpty) ...[
            const SizedBox(height: 20),

            _buildImportanceSection(
              title: 'Importance of Puja',
              html : importance,
            ),
          ],

          if (materials.isNotEmpty) ...[
            const SizedBox(height: 20),

            _buildSection(
              title: 'Puja Materials',
              child: _buildPujaMaterials(materials),
            ),
          ],

          if (pdfUrl.isNotEmpty) ...[
            const SizedBox(height: 20),

            _buildPdfButton(pdfUrl),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.orangeMain,
            ),
          ),
          Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        height: 2,
        width: double.infinity,
        color: AppColors.orangeMain,
      ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }

  Widget _buildImportanceSection({
  required String title,
  required String html,
}) {
  final document = parse.parse(html);
  final liElements = document.querySelectorAll('li');

  return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ), child:Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.orangeMain,
        ),
      ),

      // Line below header
      Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        height: 2,
        width: double.infinity,
        color: AppColors.orangeMain,
      ),

      if (liElements.isEmpty)
        Html(
          data: html,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(14),
              lineHeight: const LineHeight(1.5),
              color: Colors.black87,
            ),
          },
        )
      else
        ...List.generate(liElements.length, (index) {
          final element = liElements[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Html(
                    data: element.innerHtml,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                        lineHeight: const LineHeight(1.5),
                        color: Colors.black87,
                      ),
                      'p': Style(
                        margin: Margins.zero,
                      ),
                    },
                  ),
                ),
              ],
            ),
          );
        }),
    ],
      ),
  );
}

  Widget _buildPujaMaterials(List<dynamic> materials) {
  return Column(
    children: materials.map<Widget>((material) {
      final key = material['key']?.toString() ?? '';
      final value = material['value']?.toString() ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          iconColor: const Color(0xFFFA6400),
          collapsedIconColor: const Color(0xFFFA6400),
          title: Text(
            key,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

  Widget _buildPdfButton(String pdfUrl) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          debugPrint(
            'Open Puja PDF: $pdfUrl',
          );

          // PDF viewer/browser navigation
          // can be added here.
        },
        icon: const Icon(
          Icons.picture_as_pdf,
          color: Colors.white,
        ),
        label: const Text(
          'View Puja Materials PDF',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFA6400),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
    );
    
  }
}