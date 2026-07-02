import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  Color getStatusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFFDF2E9);

      case 'pending':
        return const Color(0xFFFEF9E7);

      case 'completed':
        return const Color(0xFFEAECEE);

      case 'cancelled':
        return const Color(0xFFFFEBEE);

      default:
        return const Color(0xFFF1F3F5);
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFD35400);

      case 'pending':
        return const Color(0xFFF39C12);

      case 'completed':
        return const Color(0xFF5D6D7E);

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.black54;
    }
  }

  String getActionLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'MANAGE BOOKING';

      case 'completed':
        return 'VIEW DETAILS';

      default:
        return 'DOWNLOAD RECEIPT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status =
        (booking['status'] ?? 'Pending').toString();

    final String title =
        booking['title'] ??
        booking['service_name'] ??
        'Booking';

    final String imageUrl =
        booking['image'] ?? '';

    final String category =
        booking['category'] ??
        booking['booking_type'] ??
        '';

    final String dateTime =
        booking['created_at'] ?? '';

    final dynamic bookingId =
        booking['id'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BOOKING #$bookingId',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getStatusBackground(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: getStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          /// Image + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    /// Category
                    Row(
                      children: [
                        Icon(
                          Icons.widgets_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Bottom Buttons
          Row(
            children: [

              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF1F3F5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // TODO
                    },
                    child: Text(
                      getActionLabel(status),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    // TODO
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}