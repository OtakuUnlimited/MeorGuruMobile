import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../constants.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../../backend/services/content_services.dart';

class PatroScreen extends StatefulWidget {
  const PatroScreen({Key? key}) : super(key: key);

  @override
  State<PatroScreen> createState() => _PatroScreenState();
}

class _PatroScreenState extends State<PatroScreen> {
  final ContentService _contentService = ContentService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _patros = [];

  @override
  void initState() {
    super.initState();
    _loadPatros();
  }

  Future<void> _loadPatros() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _contentService.fetchPatroData();

      if (!mounted) return;

      setState(() {
        _patros = result;
        _loading = false;
      });
    } catch (e) {
      debugPrint('PATRO LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load Patro.';
      });
    }
  }

  String _getPdfUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      return '';
    }

    String pdfUrl = url.toString();

    // Android emulator
    if (pdfUrl.contains('127.0.0.1:8000')) {
      pdfUrl = pdfUrl.replaceFirst(
        '127.0.0.1:8000',
        '10.0.2.2:8000',
      );
    }

    return pdfUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: const CustomTopNavBar(
        title: 'Patro',
        style: NavBarStyle.BrandedLight,
        showBack: true,
        showCart: true,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadPatros,
                  child: _patros.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 150),
                            Center(
                              child: Text(
                                'No Patro available.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text(
                              'Panchang / Patro',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'View the Patro for your region.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 20),

                            ..._patros.map(
                              (patro) => _buildPatroCard(patro),
                            ),
                          ],
                        ),
                ),

      bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 1,
      ),
    );
  }

  Widget _buildPatroCard(
    Map<String, dynamic> patro,
  ) {
    final country =
        patro['country']?.toString() ?? 'Patro';

    final pdfUrl =
        _getPdfUrl(patro['file_url']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.orangeMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.orangeMain,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    country,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'View Panchang / Patro',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton(
              onPressed: pdfUrl.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatroPdfScreen(
                            title: country,
                            pdfUrl: pdfUrl,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMain,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            onPressed: _loadPatros,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMain,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// PATRO PDF SCREEN
// ============================================================

class PatroPdfScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PatroPdfScreen({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  State<PatroPdfScreen> createState() =>
      _PatroPdfScreenState();
}

class _PatroPdfScreenState extends State<PatroPdfScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey =
      GlobalKey<SfPdfViewerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border,
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),

      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,

        onDocumentLoadFailed:
            (PdfDocumentLoadFailedDetails details) {
          debugPrint(
            'PATRO PDF ERROR: ${details.description}',
          );
        },
      ),
    );
  }
}