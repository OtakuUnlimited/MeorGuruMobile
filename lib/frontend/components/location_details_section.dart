import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';

class LocationDetailsSection extends StatefulWidget {
  final TextEditingController suburbController;
  final TextEditingController postCodeController;
  final TextEditingController addressController;
  final String? initialCountry;
  final String? initialState;
  final bool enabled;


  final Function(String?, String?) onCountryChanged;

  const LocationDetailsSection({
    super.key,
    required this.suburbController,
    required this.postCodeController,
    required this.addressController,
    required this.onCountryChanged,
    this.initialCountry,
    this.initialState,
    this.enabled = false,
  });

  @override
  State<LocationDetailsSection> createState() =>
      _LocationDetailsSectionState();
}

class _LocationDetailsSectionState extends State<LocationDetailsSection> {
  List<dynamic> countries = [];
  List<String> states = [];

  String? selectedCountry;
  String? selectedState;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/json/state.json',
      );

      countries = json.decode(response);

      print(countries.first);
      print(countries.first['states']);

      print("Countries count: ${countries.length}");
      print(countries.first);

      if (countries.isNotEmpty) {
        selectedCountry =
    widget.initialCountry ?? countries.first['name'];

        final country = countries.firstWhere(
          (e) => e['name'] == selectedCountry,
          orElse: () => countries.first,
        );

        states = (country['states'] as List<dynamic>)
            .map<String>((e) => e['name'].toString())
            .toList();

        selectedState =
            widget.initialState ??
            (states.isNotEmpty ? states.first : null);

        widget.onCountryChanged(
          selectedCountry,
          selectedState,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFFFEFEA),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFE0531A),
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

          const SizedBox(height: 16),

          _buildCountryDropdown(),

          _buildDropdownRow(
            'State/Province',
            selectedState,
            states,
            (val) {
              setState(() {
                selectedState = val;
              });

              widget.onCountryChanged(
              selectedCountry,
              selectedState,
            );
            },
          ),

          _buildInlineInputRow(
            'Suburb/City',
            widget.suburbController,
            fallbackHint: 'Enter city',
          ),

          _buildInlineInputRow(
            'Post Code',
            widget.postCodeController,
            fallbackHint: 'Enter post code',
            isHighlight: true,
          ),

          _buildInlineInputRow(
            'Full Address',
            widget.addressController,
            fallbackHint: 'Enter full address',
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Country*',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),

          SizedBox(
            width: 170,
            child: IgnorePointer(
              ignoring: !widget.enabled,
              child: DropdownSearch<String>(
                selectedItem: selectedCountry,

              // realtime filtering
              items: (filter, infiniteScrollProps) {
                return countries
                    .map<String>((c) => c['name'].toString())
                    .where(
                      (country) => country
                          .toLowerCase()
                          .contains(filter.toLowerCase()),
                    )
                    .toList();
              },

              popupProps: PopupProps.menu(
                showSearchBox: true,

                // filter while typing
                searchDelay: Duration.zero,

                fit: FlexFit.loose,

                searchFieldProps: const TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search country',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),

              // remove extra padding around selected item
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),

              dropdownBuilder: (context, selectedItem) {
                return Text(
                  selectedItem ?? '',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },

              onChanged: (val) {
                if (val == null) return;

                setState(() {
                  selectedCountry = val;

                  final country = countries.firstWhere(
                    (e) => e['name'] == val,
                  );

                  states = (country['states'] as List<dynamic>)
                      .map<String>((e) => e['name'].toString())
                      .toList();

                  // select first state automatically
                  selectedState =
                      states.isNotEmpty ? states.first : null;
                });
              },
            ),
          ),
          ),
        ],
      ),

      Divider(
        color: Colors.grey.shade200,
        height: 1,
      ),
    ],
  );
}

  Widget _buildDropdownRow(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
              DropdownButton<String>(
                value: options.contains(value) ? value : null,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                items: options.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
                onChanged: widget.enabled ? onChanged : null,
              ),
            ],
          ),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildInlineInputRow(
    String label,
    TextEditingController controller, {
    required String fallbackHint,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
              SizedBox(
                width: 140,
                child: TextFormField(
                  enabled: widget.enabled,
                  controller: controller,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: isHighlight
                        ? const Color(0xFFB33A0F)
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: fallbackHint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      decoration: fallbackHint.isEmpty
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ],
      ),
    );
  }
}