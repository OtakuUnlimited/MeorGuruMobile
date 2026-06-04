import 'package:flutter/material.dart';

class LocationDetailsWidget extends StatelessWidget {
  final String country;
  final String state;
  final String suburb;
  final String address;

  const LocationDetailsWidget({
    super.key,
    required this.country,
    required this.state,
    required this.suburb,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFEFEA),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFB33A0F),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Location Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _buildRow('Country', country),

        _buildRow('State/Province', state),

        _buildRow('Suburb/City', suburb),

        _buildRow(
          'Address',
          address,
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHighlight
                        ? const Color(0xFFB33A0F)
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFFEEEEEE),
          ),
        ],
      ),
    );
  }
}