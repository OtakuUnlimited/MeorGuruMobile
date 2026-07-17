import 'package:flutter/material.dart';

class ServiceDetailsCard extends StatelessWidget {
  final Map<String, dynamic> guru;

  const ServiceDetailsCard({
    Key? key,
    required this.guru,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert services into a list
    List<String> services = [];

    if (guru['service'] != null &&
        guru['service'].toString().trim().isNotEmpty) {
      services = guru['service']
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Convert availability
    List<String> availability = [];
    if (guru['availability'] is List) {
      availability =
          List<String>.from(guru['availability'].map((e) => e.toString()));
    } else if (guru['availability'] != null &&
        guru['availability'].toString().isNotEmpty) {
      availability = [guru['availability'].toString()];
    }

    // Convert service areas
    List<String> serviceAreas = [];
    if (guru['servicearea'] is List) {
      serviceAreas =
          List<String>.from(guru['servicearea'].map((e) => e.toString()));
    } else if (guru['servicearea'] != null &&
        guru['servicearea'].toString().isNotEmpty) {
      serviceAreas = [guru['servicearea'].toString()];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5).withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Service Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.layers_outlined,
                color: Colors.amber.shade800,
              ),
            ],
          ),

          const SizedBox(height: 16),

          services.isEmpty
              ? const Text(
                  "No services available",
                  style: TextStyle(color: Colors.grey),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services
                      .map(
                        (service) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  "EXPERIENCE",
                  guru['experience']?.toString() ?? "-",
                ),
              ),
              Expanded(
                child: _buildMetric(
                  "AVAILABILITY",
                  availability.isEmpty
                      ? "-"
                      : availability.join(", "),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  "SERVICE AREAS",
                  serviceAreas.isEmpty
                      ? "-"
                      : serviceAreas.join(", "),
                ),
              ),
              Expanded(
                child: _buildMetric(
                  "DO YOU DRIVE",
                  guru['do_you_drive']?.toString() ?? "-",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}