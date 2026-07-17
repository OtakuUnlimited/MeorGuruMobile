import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../backend/services/content_services.dart';
import '../../../routes/app_routes.dart';

class PopularVenuesSection extends StatelessWidget {
  const PopularVenuesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future:
          ContentService()
              .fetchPopularVenues(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final venues =
            snapshot.data!.take(5).toList();

        return SizedBox(
          height: 320,

          child: ListView.builder(
            scrollDirection:
                Axis.horizontal,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            itemCount: venues.length,

            itemBuilder: (context, index) {

              final venue =
                  venues[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.serviceDetails,
                    arguments: venue['slug'],
                  );
                },
              child: Container(
                width: 240,

                margin:
                    const EdgeInsets.only(
                  right: 14,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.08),
                      blurRadius: 8,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    ClipRRect(
                      borderRadius:
                          const BorderRadius
                              .vertical(
                        top:
                            Radius.circular(
                          18,
                        ),
                      ),

                      child: Image.network(
                        venue['image'] ?? '',

                        height: 150,

                        width:
                            double.infinity,

                        fit: BoxFit.cover,

                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            height: 150,
                            color: Colors
                                .grey.shade200,
                            child:
                                const Icon(
                              Icons.image,
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .all(14),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            venue['title'] ??
                                '',

                            maxLines: 2,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            venue['state'] ??
                                'Australia',

                            maxLines: 1,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          SizedBox(
                            width:
                                double.infinity,

                            height: 42,

                            child:
                                ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.serviceDetails,
                                  arguments: venue['slug'],
                                );
                              },

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    AppColors
                                        .maroonRed,

                                foregroundColor:
                                    Colors
                                        .white,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    25,
                                  ),
                                ),
                              ),

                              child:
                                  const Text(
                                "View Details",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              );
            },
          ),
        );
      },
    );
  }
} 