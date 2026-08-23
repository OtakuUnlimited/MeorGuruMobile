import 'package:flutter/material.dart';
import '../components/form/event_package_form.dart';
import '../components/top_nav_bar.dart';

class EventPackagesOrderScreen
    extends StatelessWidget {
  final Map<String, dynamic>
      eventPackageData;

  const EventPackagesOrderScreen({
    Key? key,
    required this.eventPackageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title =
        eventPackageData['title']
                ?.toString() ??
            'Event Package';

    final String image =
        eventPackageData['image']
                ?.toString() ??
            '';

    final String price =
        eventPackageData['price']
                ?.toString() ??
            '0';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA),

      appBar: const CustomTopNavBar(
        title: 'Mero Guru',
        showBack: true,
        style: NavBarStyle.BrandedLight,
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            // ==========================================
            // IMAGE
            // ==========================================

            Center(
              child:
                  Container(
                width: 140,
                height: 140,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  border:
                      Border.all(
                    color:
                        Colors.white,
                    width: 2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.05,
                      ),
                      blurRadius:
                          10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child:
                    ClipOval(
                  child:
                      image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit
                                  .cover,
                              errorBuilder:
                                  (
                                _,
                                __,
                                ___,
                              ) {
                                return const Icon(
                                  Icons
                                      .auto_awesome,
                                  size:
                                      60,
                                  color:
                                      Color(
                                    0xFFFA6400,
                                  ),
                                );
                              },
                            )
                          : const Icon(
                              Icons
                                  .auto_awesome,
                              size: 60,
                              color:
                                  Color(
                                0xFFFA6400,
                              ),
                            ),
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==========================================
            // TITLE
            // ==========================================

            Text(
              title,
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFFFA6400),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // ==========================================
            // PRICE
            // ==========================================

            Text(
              '\$$price',

              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.black87,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==========================================
            // EVENT FORM
            // ==========================================

            EventPackageForm(
              eventPackageData:
                  eventPackageData,

              onPaymentSubmit:
                  () {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Processing Order...',
                    ),
                    backgroundColor:
                        Colors.green,
                  ),
                );
              },
            ),

            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}