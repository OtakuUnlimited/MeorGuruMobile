import 'package:flutter/material.dart';

class ServiceDetailsCard extends StatelessWidget {
  const ServiceDetailsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = ['Satyanarayan Puja', 'Marriage', 'Ghar Puja', 'Bratabandha', 'Graha Shanti', 'Antyesti'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5).withOpacity(0.6), // Light muted grey box
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Service Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(Icons.layers_outlined, color: Colors.amber.shade800, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          
          // White tags wrap matrix
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),

          // Core metric layout grid
          Row(
            children: [
              Expanded(child: _buildMetric('EXPERIENCE', '15 Year(s)')),
              Expanded(child: _buildMetric('AVAILABILITY', 'Full Time')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetric('SERVICE AREAS', 'Sydney')),
              Expanded(child: _buildMetric('DO YOU DRIVE', 'Yes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(state, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}