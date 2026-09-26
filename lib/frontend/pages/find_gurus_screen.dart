import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import 'guru_profile_screen.dart';
import '../components/utils/phone_formatter.dart';

class FindGurusScreen extends StatefulWidget {
  const FindGurusScreen({Key? key}) : super(key: key);

  @override
  State<FindGurusScreen> createState() => _FindGurusScreenState();
}

class _FindGurusScreenState extends State<FindGurusScreen> {
  late Future<List<dynamic>> gurusFuture;

  @override
  void initState() {
    super.initState();
    gurusFuture = ContentService().fetchAllGurus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavBar(
        title: "Gurus",
        showMenu: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: gurusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No gurus found"),
            );
          }

          final gurus = snapshot.data!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _buildDropdownFilter(
                        "State/Province",
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownFilter(
                        "Suburb/City",
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownFilter(
                        "Sort By",
                        hasTrailing: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildGuruGridCard(
                        context,
                        gurus[index],
                      );
                    },
                    childCount: gurus.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(activeIndex: 4),
    );
  }

  Widget _buildDropdownFilter(
    String label, {
    bool hasTrailing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderGray,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          Icon(
            hasTrailing
                ? Icons.keyboard_arrow_down
                : Icons.arrow_drop_down,
            color: AppColors.brownAccent,
          )
        ],
      ),
    );
  }

  Widget _buildGuruGridCard(
    BuildContext context,
    dynamic guru,
  ) {
    final avatar = guru['avatar'] ?? '';

    final firstName = guru['first_name'] ?? '';
    final middleName = guru['middle_name'] ?? '';
    final lastName = guru['last_name'] ?? '';

    final fullName =
        "$firstName ${middleName ?? ''} $lastName"
            .replaceAll("null", "")
            .trim();

    final location =
        guru['address'] ?? 'Location unavailable';

    final phone =
        guru['phone'] ?? 'Not Available';

    final slug = guru['slug'] ?? '';

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.borderGray,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: avatar.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        avatar,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 11,
                      color:
                          AppColors.greenAccent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        formatAustralianPhone(phone),
                        style:
                            const TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                          color: AppColors
                              .textDark,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color:
                            AppColors.maroonRed,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GuruProfileScreen(
                            slug: slug,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        color:
                            AppColors.maroonRed,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}