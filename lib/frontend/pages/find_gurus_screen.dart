import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';
import 'guru_profile_screen.dart';
import '../components/utils/phone_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class FindGurusScreen extends StatefulWidget {
  const FindGurusScreen({Key? key}) : super(key: key);

  @override
  State<FindGurusScreen> createState() => _FindGurusScreenState();
}

class _FindGurusScreenState extends State<FindGurusScreen> {
  final ContentService _contentService =
    ContentService();

List<Map<String, dynamic>> _gurus = [];
List<String> _states = [];
List<String> _suburbs = [];

String? _selectedState;
String? _selectedSuburb;
String? _selectedSort;

bool _initialLoading = true;
bool _filterLoading = false;
String? _error;

@override
void initState() {
  super.initState();
  _loadGurus(initialLoad: true);
}

Future<void> _loadGurus({
  bool initialLoad = false,
}) async {
  if (initialLoad) {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
  } else {
    setState(() {
      _filterLoading = true;
      _error = null;
    });
  }

  try {
    final response =
        await _contentService.fetchGuruDirectory(
      state: _selectedState,
      suburb: _selectedSuburb,
    );

    final gurus =
        List<Map<String, dynamic>>.from(
      response['users'] as List,
    );

    final states = List<String>.from(
      response['states'] as List,
    );

    final suburbs = List<String>.from(
      response['suburbs'] as List,
    );

    _sortGurus(gurus);

    if (!mounted) return;

    setState(() {
      _gurus = gurus;
      _states = states;
      _suburbs = suburbs;
      _initialLoading = false;
      _filterLoading = false;
    });
  } catch (error, stackTrace) {
    debugPrint(
      'LOAD GURUS ERROR: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    setState(() {
      _error = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('HttpException: ', '');

      _initialLoading = false;
      _filterLoading = false;
    });
  }
}

String _guruName(
  Map<String, dynamic> guru,
) {
  final names = [
    guru['first_name'],
    guru['middle_name'],
    guru['last_name'],
  ];

  return names
      .where(
        (name) =>
            name != null &&
            name.toString().trim().isNotEmpty,
      )
      .map(
        (name) => name.toString().trim(),
      )
      .join(' ');
}

void _sortGurus(
  List<Map<String, dynamic>> gurus,
) {
  if (_selectedSort == 'name_asc') {
    gurus.sort(
      (first, second) => _guruName(first)
          .toLowerCase()
          .compareTo(
            _guruName(second).toLowerCase(),
          ),
    );
  }

  if (_selectedSort == 'name_desc') {
    gurus.sort(
      (first, second) => _guruName(second)
          .toLowerCase()
          .compareTo(
            _guruName(first).toLowerCase(),
          ),
    );
  }
}

void _applySort(String? value) {
  setState(() {
    _selectedSort = value;

    final sorted =
        List<Map<String, dynamic>>.from(
      _gurus,
    );

    _sortGurus(sorted);
    _gurus = sorted;
  });
}

void _clearFilters() {
  setState(() {
    _selectedState = null;
    _selectedSuburb = null;
    _selectedSort = null;
  });

  _loadGurus();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavBar(
        title: "Gurus",
        showMenu: true,
        style: NavBarStyle.BrandedLight,
      ),
      body: _initialLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadGurus(
                        initialLoad: true,
                      );
                    },
                    child: const Text(
                      'Try Again',
                    ),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              CustomScrollView(
                physics:
                    const BouncingScrollPhysics(),
                slivers: [
                  /*
                   * Filters
                   */
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          /*
                           * State filter
                           */
                          _buildSearchableFilter(
                            label:
                                'State/Province',
                            items: _states,
                            selectedValue:
                                _selectedState,
                            onChanged: (state) {
                              if (state ==
                                  _selectedState) {
                                return;
                              }

                              setState(() {
                                _selectedState =
                                    state;

                                /*
                                 * Clear suburb because
                                 * available suburbs depend
                                 * on the selected state.
                                 */
                                _selectedSuburb =
                                    null;
                                _suburbs = [];
                              });

                              _loadGurus();
                            },
                          ),

                          const SizedBox(height: 8),

                          /*
                           * Suburb filter
                           */
                          _buildSearchableFilter(
                            label:
                                'Suburb/City',
                            items: _suburbs,
                            selectedValue:
                                _selectedSuburb,
                            onChanged: (suburb) {
                              if (suburb ==
                                  _selectedSuburb) {
                                return;
                              }

                              setState(() {
                                _selectedSuburb =
                                    suburb;
                              });

                              _loadGurus();
                            },
                          ),

                          const SizedBox(height: 8),

                          /*
                           * A-Z / Z-A sorting
                           */
                          _buildSortDropdown(),

                          const SizedBox(height: 4),

                          /*
                           * Clear filters
                           */
                          Align(
                            alignment:
                                Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed:
                                  _filterLoading
                                      ? null
                                      : _clearFilters,
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                              ),
                              label: const Text(
                                'Clear Filters',
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  /*
                   * Empty result
                   */
                  if (_gurus.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .person_search_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No gurus found',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )

                  /*
                   * Guru grid
                   */
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.only(
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
                        delegate:
                            SliverChildBuilderDelegate(
                          (
                            context,
                            index,
                          ) {
                            return _buildGuruGridCard(
                              context,
                              _gurus[index],
                            );
                          },
                          childCount:
                              _gurus.length,
                        ),
                      ),
                    ),
                ],
              ),

              /*
               * Loading indicator while changing
               * filters. The existing screen remains
               * visible behind the overlay.
               */
              if (_filterLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.white
                          .withOpacity(0.35),
                      alignment:
                          Alignment.center,
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                0.08,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child:
                            const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      bottomNavigationBar:
          const CustomBottomNavBar(activeIndex: 4),
    );
  }

  Widget _buildSearchableFilter({
  required String label,
  required List<String> items,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownSearch<String>(
    selectedItem: selectedValue,
    items: (
      filter,
      infiniteScrollProps,
    ) {
      final search =
          filter.trim().toLowerCase();

      if (search.isEmpty) {
        return items;
      }

      return items.where(
        (item) => item
            .toLowerCase()
            .contains(search),
      ).toList();
    },
    popupProps: PopupProps.menu(
      showSearchBox: true,
      fit: FlexFit.loose,
      searchDelay: Duration.zero,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          hintText: 'Search $label',
          prefixIcon:
              const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    decoratorProps: DropDownDecoratorProps(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderGray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderGray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.brownAccent,
          ),
        ),
      ),
    ),
    onChanged: onChanged,
  );
}
Widget _buildSortDropdown() {
  return DropdownButtonFormField<String>(
    value: _selectedSort,
    decoration: InputDecoration(
      labelText: 'Sort By',
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.borderGray,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.borderGray,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.brownAccent,
        ),
      ),
    ),
    items: const [
      DropdownMenuItem(
        value: 'name_asc',
        child: Text('Name (A–Z)'),
      ),
      DropdownMenuItem(
        value: 'name_desc',
        child: Text('Name (Z–A)'),
      ),
    ],
    onChanged: _applySort,
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