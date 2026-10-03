import 'package:flutter/material.dart';

import '../../backend/services/content_services.dart';
import '../components/puja_material_card.dart';
import '../../routes/app_routes.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';

class PujaMaterialsScreen extends StatefulWidget {
  const PujaMaterialsScreen({Key? key}) : super(key: key);

  @override
  State<PujaMaterialsScreen> createState() => _PujaMaterialsScreenState();
}

class _PujaMaterialsScreenState extends State<PujaMaterialsScreen> {
  final ContentService _contentService = ContentService();

  List<Map<String, dynamic>> _pujas = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPujaMaterials();
  }

  Future<void> _loadPujaMaterials() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _contentService.fetchPujaMaterials();

      if (!mounted) return;

      setState(() {
        _pujas = result
            .map(
              (item) => Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PUJA MATERIAL SCREEN ERROR: $e');

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

      // App Bar matching the original design
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

              const Text(
                'Unable to load Puja Materials',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loadPujaMaterials,
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

    if (_pujas.isEmpty) {
      return const Center(
        child: Text(
          'No Puja Materials available.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPujaMaterials,
      color: const Color(0xFFFA6400),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        itemCount: _pujas.length,
        itemBuilder: (context, index) {
          final puja = _pujas[index];

          final title =
              puja['nepali_title']?.toString().trim().isNotEmpty == true
                  ? puja['nepali_title'].toString()
                  : puja['title']?.toString() ?? '';

          final description =
              puja['sub_title']?.toString() ?? '';

          final imageUrl =
              puja['image']?.toString() ?? '';

          return PujaMaterialCard(
            title: title,
            description: description,
            imageUrl: imageUrl,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.pujaMaterialDetail,
                arguments: puja['slug']?.toString(),
              );
            },
            
          );
          
        },
        
      ),

      
    );
    
  }
}