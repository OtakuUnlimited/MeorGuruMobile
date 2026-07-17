import 'package:flutter/material.dart';
import '../components/form/online_puja_form.dart';

class OnlinePujaOrderScreen extends StatelessWidget {
  final Map<String, dynamic> pujaData;

  const OnlinePujaOrderScreen({
    Key? key,
    required this.pujaData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = pujaData['title'] ?? 'Online Puja';
    final String image = pujaData['image'] ?? '';
    final String price = pujaData['price']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFFFA6400),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFFA6400),
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Image
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.temple_hindu,
                              size: 60,
                              color: Color(0xFFFA6400),
                            );
                          },
                        )
                      : const Icon(
                          Icons.temple_hindu,
                          size: 60,
                          color: Color(0xFFFA6400),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA6400),
              ),
            ),

            const SizedBox(height: 8),

            /// Price
            Text(
              '\$$price',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            /// Online Puja Form
            OnlinePujaForm(
              puja: pujaData,
              onPaymentSubmit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing Order...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}