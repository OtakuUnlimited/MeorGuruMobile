import 'package:flutter/material.dart';

import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final ContentService _contentService =
      ContentService();

  List<dynamic> bookings = [];
  List<dynamic> filteredBookings = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadBookings();

    _searchController.addListener(() {
      filterBookings();
    });
  }

  Future<void> loadBookings() async {
    try {
      final response =
          await _contentService.fetchUserBookings();

      if (!mounted) return;

      setState(() {
        bookings = response;
        filteredBookings = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void filterBookings() {
    final query =
        _searchController.text.toLowerCase();

    setState(() {
      filteredBookings = bookings.where((booking) {
        final title =
            (booking['title'] ??
                    booking['service_name'] ??
                    '')
                .toString()
                .toLowerCase();

        return title.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// Header
            const Text(
              'My Bookings / Orders',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0531A),
              ),
            ),

            const SizedBox(height: 16),

            /// Search box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: TextField(
                controller: _searchController,

                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Loading
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )

            /// Empty state
            else if (filteredBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    "No bookings found",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )

            /// Booking list
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: filteredBookings.length,

                itemBuilder: (context, index) {
                  return BookingCard(
                    booking:
                        filteredBookings[index],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}