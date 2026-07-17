import 'package:flutter/material.dart';

class LocationDetailsBlock extends StatelessWidget {
  final Map<String, dynamic> guru;

  const LocationDetailsBlock({
    Key? key,
    required this.guru,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFEFEA),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.amber.shade800,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Location Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            'Country',
            guru['country']?.toString() ?? '-',
          ),

          _buildInfoRow(
            'State/Province',
            guru['state']?.toString() ?? '-',
          ),

          _buildInfoRow(
            'Suburb/City',
            guru['suburb']?.toString() ?? '-',
          ),

          _buildInfoRow(
            'Post Code',
            guru['postal_code']?.toString() ?? '-',
            isHighlight: true,
          ),

          if ((guru['address'] ?? '').toString().isNotEmpty)
            _buildInfoRow(
              'Address',
              guru['address'].toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isHighlight
                    ? Colors.amber.shade900
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}